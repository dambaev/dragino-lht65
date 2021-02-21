#define ATS_PACKNAME "dragino-lht65"
#define ATS_EXTERN_PREFIX "dragino-lht65"
#include "share/atspre_staload.hats" // include template definitions

#define LIBS_targetloc "../libs" (* search path for external libs *)
staload BS="{$LIBS}/ats-bytestring/SATS/bytestring.sats"

datavtype LHT65Ext_sensor =
  | Temperature of double
  | Interrupt of
    @{ is_pin_level_high = bool // true - high, false - low
    , is_interrupt_uplink = bool
    }
  | Illumination of uint16 // lux
  | ADC of double
  | Counting of uint16

vtypedef LHT65Message =
  @{ BatV = uint16 // mV
  , TempC_SHT = double // f
  , Hum_SHT = double // %
  , Ext_value = Option_vt( LHT65Ext_sensor)
  }

fn
  free_lht65message
  ( i: LHT65Message
  ):<!wrt>
  void

fn
  parse
  {len,offset,cap,ucap,refcnt: nat | len >= 7}{dynamic:bool}{l:addr}
  ( i: !$BS.Bytestring_vtype(len, offset, cap, ucap, refcnt, dynamic, l)
  ):<!wrt>
  Option_vt( LHT65Message)

fn
  lht65_to_bs
  ( i: !LHT65Message
  ):<!wrt>
  $BS.BytestringNSH1
