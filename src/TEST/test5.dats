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
                      , i2c 0x05
                      , i2c 0x01, i2c 0x91
                      , i2c 0x7F, i2c 0xFF
                      )
  val i = $BS.pack( view@ packet | addr@packet, i2sz 11, i2sz 11)
  val-~Some_vt( m ) = parse( i)

  val bs = lht65_to_bs( m)
  val () = $BS.printlnC bs

  val- Some_vt( ext) = m.Ext_value
  val- Illumination(v) = ext
  val () = assertloc( v = $UN.cast{uint16} 401)
  
  val () = free_lht65message( m)
  val () = free( view@packet | i)
}

fn
  test1(): void = {
  var packet = @[char]( i2c 0xCB, i2c 0xF6 // BatV
                      , i2c 0x0B, i2c 0x0D // tempc_sht
                      , i2c 0x03, i2c 0x76 // hum_sht
                      , i2c 0x85
                      , i2c 0xFF, i2c 0xFF
                      , i2c 0x7F, i2c 0xFF
                      )
  val i = $BS.pack( view@ packet | addr@packet, i2sz 11, i2sz 11)
  val-~Some_vt( m ) = parse( i)

  val bs = lht65_to_bs( m)
  val () = $BS.printlnC bs

  val- None_vt( ) = m.Ext_value
  
  val () = free_lht65message( m)
  val () = free( view@packet | i)
}


implement main0() = 
  ( test0()
  ; test1()
  )
