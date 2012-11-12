unit ascii;
interface

const
  NUL = #00; { ^@ null character             }
  SOH = #01; { ^A start of header            }
  STX = #02; { ^B start text                 }
  ETX = #03; { ^C end text                   }
  EOT = #04; { ^D end of transmission        }
  ENQ = #05; { ^E enquiry                    }
  ACK = #06; { ^F acknowledge                }
  BEL = #07; { ^G bell                       }
  BS  = #08; { ^H backspace                  }
  HT  = #09; { ^I horizontal tab             }
  LF  = #10; { ^J linefeed                   }
  VT  = #11; { ^K vertical tab               }
  FF  = #12; { ^L form feed                  }
  CR  = #13; { ^M carriage return            }
  SO  = #14; { ^N shift out                  }
  SI  = #15; { ^O shift in                   }
  DLE = #16; { ^P data link escape           }
  DC1 = #17; { ^Q device control 1 ( XON )   }
  DC2 = #18; { ^R device control 2           }
  DC3 = #19; { ^S device control 3 ( XOFF )  }
  DC4 = #20; { ^T device control 4           }
  NAK = #21; { ^U negative acknowledge       }
  SYN = #22; { ^V sychronous idle            }
  ETB = #23; { ^W end of transmission block  }
  CAN = #24; { ^X cancel                     }
  EM  = #25; { ^Y end of medium              }
  SUB = #26; { ^Z substitute                 }
  ESC = #27; { ^[ escape                     }
  FS  = #28; { ^\ file separator             }
  GS  = #29; { ^] group separator            }
  RS  = #30; { ^^ record separator           }
  US  = #31; { ^_ unit separator             }

implementation
end.
