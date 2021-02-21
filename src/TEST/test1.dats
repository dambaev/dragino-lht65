#include "share/atspre_staload.hats"

#define ATS_DYNLOADFLAG 0
staload "./../SATS/dragino-lht65.sats"

#define LIBS_targetloc "../libs" (* search path for external libs *)
#include "{$LIBS}/ats-bytestring/HATS/bytestring.hats"
staload UN="prelude/SATS/unsafe.sats"

fn i2c( i: int):<> char = $UN.cast{char} i

fn
  test0(): void = {
  var packet = @[char]( i2c 0xCB, i2c 0xF6 // BatV
                      , i2c 0x0B, i2c 0x0D // tempc_sht
                      , i2c 0x03, i2c 0x76 // hum_sht
                      , i2c 0x00
                      )
  val i = $BS.pack( view@ packet | addr@packet, i2sz 7, i2sz 7)
  val-~Some_vt( m) = parse( i)
  val bs = lht65_to_bs( m)
  val () = $BS.printlnC bs
  val () = assertloc( m.BatV = $UN.cast{uint16} 3062)
  val () = assertloc( m.TempC_SHT = 28.29)
  val () = assertloc( m.Hum_SHT = 88.6)
  val () = free_lht65message( m)
  val () = free( view@packet | i)
}

fn
  test1(): void = {
  var packet = @[char]( i2c 0xCB, i2c 0xF6 // BatV
                      , i2c 0xF5, i2c 0xC6 // tempc_sht
                      , i2c 0x03, i2c 0x76 // hum_sht
                      , i2c 0x00
                      )
  val i = $BS.pack( view@ packet | addr@packet, i2sz 7, i2sz 7)
  val-~Some_vt( m) = parse( i)
  val bs = lht65_to_bs( m)
  val () = $BS.printlnC bs
  val () = assertloc( m.BatV = $UN.cast{uint16} 3062)
  val () = assertloc( m.TempC_SHT = ~26.18)
  val () = assertloc( m.Hum_SHT = 88.6)
  val () = free_lht65message( m)
  val () = free( view@packet | i)
}

implement main0() = 
  ( test0()
  ; test1()
  )
