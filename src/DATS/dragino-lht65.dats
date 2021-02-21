#include "share/atspre_staload.hats"

#define ATS_DYNLOADFLAG 0
staload "./../SATS/dragino-lht65.sats"

#define LIBS_targetloc "../libs" (* search path for external libs *)
#include "{$LIBS}/ats-bytestring/HATS/bytestring.hats"
staload UN="prelude/SATS/unsafe.sats"

%{^
#include "arpa/inet.h"
%}

// define missing operators
infixr (+) .|.
overload .|. with g0uint_lor_uint16
infixr ( * ) &
overload & with g0uint_land_uint16
overload & with g0uint_land_uint32
infixr (+) >>
overload >> with g0uint_lsr_uint16
infixr (+) <<
overload << with g0uint_lsl_uint16

implement free_lht65message( m ) =
  case+ m.Ext_value of
  | ~None_vt() => ()
  | ~Some_vt( sensor) =>
    ( case+ sensor of
    | ~Temperature(_) => ()
    | ~Interrupt(_) => ()
    | ~Illumination(_) => ()
    | ~ADC(_) => ()
    | ~Counting(_) => ()
    )

implement lht65_to_bs( m) = ret where {
  val ext_val =
    ( case+ m.Ext_value of
    | None_vt() => $BS.pack " "
    | Some_vt( sensor) =>
      ( case+ sensor of
      | Temperature( v) => $BS.pack "\"temperature\" : " + $BS.pack v
      | Interrupt( v) => 
        $BS.pack "\"interrupt\": {"
        + $BS.pack "\"is_pin_level_high\": " + $BS.pack v.is_pin_level_high
        + $BS.pack ", \"is_interrupt_uplink\": " + $BS.pack v.is_interrupt_uplink
        + $BS.pack "}"
      | Illumination(v) => $BS.pack "\"illumination\": " + $BS.pack v
      | ADC(v) => $BS.pack "\"ADC\": " + $BS.pack v
      | Counting(v) => $BS.pack "\"counting\": " + $BS.pack v
      )
    ): $BS.BytestringNSH1
  val ret
    = $BS.pack "{"
    + $BS.pack "\"BatV\": " + $BS.pack m.BatV
    + $BS.pack ", \"TempC_SHT\": " + $BS.pack m.TempC_SHT
    + $BS.pack ", \"Hum_SHT\": " + $BS.pack m.Hum_SHT
    + $BS.pack ", \"ext\": {" + ext_val + $BS.pack "}"
    + $BS.pack "}"
}

extern castfn
  c2i(i: char):<> int

extern prfun
  bytes_takeout
  {a:t0ype}{n: nat}{l:addr}
  ( i: !array_v(char, l, n) >> ( array_v(char, l, n), a @ l)
  ):<>
  a @ l

extern prfun
  bytes_addback
  {a:t0ype}{n: nat}{l:addr}
  ( i: !( array_v(char, l, n), a @ l) >> (array_v(char, l, n))
  , i1: a @ l
  ):<> void

extern fn ntohs( uint16):<> uint16 = "mac#"
extern fn ntohl( uint32):<> uint32 = "mac#"

(* splits uint32 value on a 2 uint16 values *)
fn
  split_uint32
  (i: uint32
  ):<> (uint16, uint16) =
( $UN.cast{uint16} (i & $UN.cast{uint32} 0xffff)
, $UN.cast{uint16} (( i & $UN.cast{uint32} 0xffff0000) >> 16)
)

fn
  parse_ext_value
  ( sensor: uint8
  , value: uint32
  ):<>
  Option_vt( LHT65Ext_sensor) =
case+ $UN.cast{int} sensor of
| 0x01 => (* Temperature *)
  let
    val (_, value1) = split_uint32 value
    val value16 = $UN.cast{int16} value1
  in
    if value16 = $UN.cast{int16} 0x7FFF
    then None_vt()
    else Some_vt( Temperature(($UN.cast{double} value16) / 100.0))
  end
| 0x04 => Some_vt( Interrupt(
  @{ is_pin_level_high = is_pin_level_high = $UN.cast{uint16} 0x01
  , is_interrupt_uplink = is_interrupt_uplink = $UN.cast{uint16} 0x01
  }
  )
  ) where {
  val (_, v) = split_uint32 value
  val is_pin_level_high = (v & $UN.cast{uint16} 0xff00) >> 8
  val is_interrupt_uplink = (v & $UN.cast{uint16} 0xff)
}
| 0x05 => Some_vt( Illumination( v) ) where {
  val (_, v) = split_uint32 value
}
| 0x06 => Some_vt( ADC( v)) where {
  val (_, v1) = split_uint32( value)
  val v = ($UN.cast{double} v1) / 1000.0
}
| 0x07 => Some_vt( Counting( v)) where {
  val (_, v) = split_uint32( value)
}
| _ => None_vt()

implement parse( i) = ret where {
// define C-based structs to pattern match on raw data
%{^
#pragma pack( push, 1)
struct lht65_message_base_t {
  uint16_t f0;
  uint16_t f1;
  uint16_t f2;
  uint8_t  f3;
};
#pragma pack( pop)

#pragma pack( push, 1)
struct lht65_message_ext_t {
  uint16_t f0;
  uint16_t f1;
  uint16_t f2;
  uint8_t  f3;
  uint32_t f4;
};
#pragma pack( pop)
%}
  // LHT65 can send either base message (7 bytes)
  typedef lht65_message_base_t = $extype_struct"struct lht65_message_base_t" of
    { f0 = uint16
    , f1 = uint16
    , f2 = uint16
    , f3 = uint8
    }
  // or message with external value (11-bytes)
  typedef lht65_message_ext_t = $extype_struct"struct lht65_message_ext_t" of
    { f0 = uint16
    , f1 = uint16
    , f2 = uint16
    , f3 = uint8
    , f4 = uint32
    }
  prval _ = $BS.lemma_bytestring_param( i)
  val (pf0 | i_p, i_sz) = $BS.bs2bytes_ro i // get proof, raw pointer and size
  prval pf1 = bytes_takeout{lht65_message_base_t}(pf0) // cast pointer
  val base = !i_p // dereference pointer
  prval () = bytes_addback( pf0, pf1) // cast pointer back
  val batV = ntohs( base.f0) & $UN.cast{uint16}0x3FFF
  val tempC_sht = ($UN.cast{double} ($UN.cast{int16} (ntohs base.f1))) / 100.0
  val hum_sht = ($UN.cast{double} (ntohs base.f2)) / 10.0
  val ret =
    ( ifcase
    | i_sz = 7 && base.f3 = $UN.cast{uint8} 0 =>
      Some_vt( @{ BatV = batV
                , TempC_SHT = tempC_sht
                , Hum_SHT = hum_sht
                , Ext_value = None_vt()
                }:LHT65Message
             )
    | i_sz = 11 && base.f3 <> $UN.cast{uint8} 0 =>
      Some_vt( @{ BatV = batV
                , TempC_SHT = tempC_sht
                , Hum_SHT = hum_sht
                , Ext_value = parse_ext_value( ext.f3, ntohl( ext.f4))
                }:LHT65Message
            )
      where {
        prval pf2 = bytes_takeout{lht65_message_ext_t}(pf0) // cast pointer
        val ext = !i_p
        prval () = bytes_addback(pf0, pf2) // cast pointer back
      }
    | _ => None_vt()
    ):Option_vt(LHT65Message)
  prval () = $BS.bytes_addback( pf0 | i)
}