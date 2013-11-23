{
| block drive device
|
| -------------------------------------------------
| copyright (c) 2012,2013 michal j. wallace
| see LICENSE.org for usage information
}
{$mode objfpc}{$i xpc.inc}
unit ublockdrive;

interface uses log, fs, sysutils;

type
  TBlock   = array [ 0..1023 ] of byte;
  TBlock32 = array [ 0..255 ] of Int32;
  TBlockDrive = class
  private
    _path : string;
    _file : file of TBlock;
  public
    constructor Create( path : string );
    procedure Wipe;
    procedure Grow( n : byte );
    procedure Load( i : cardinal; var b : TBlock );
    procedure Save( i : cardinal; var b : TBlock );
    function BlockCount : cardinal;
    function ByteCount : cardinal;
    destructor Destroy; override;
  published
    property path : string read _path write _path;
  end;

implementation
var
  empty_block : TBlock;

constructor TBlockDrive.Create( path : string );
  begin
    // change to fs.open when it's ready
    fs.update( _file, path );
  end;

procedure TBlockDrive.wipe;
  begin
    seek( _file, 0 );
    truncate( _file );
  end;

procedure TBlockDrive.grow ( n : byte );
  begin
    seek( _file, filesize( _file ));
    for n := n downto 1 do write( _file, empty_block );
  end;

procedure TBlockDrive.load ( i : cardinal; var b : TBlock );
  begin
    seek( _file, i );
    read( _file, b );
  end;

procedure TBlockDrive.save ( i : cardinal; var b : TBlock );
  begin
    seek( _file, i );
    write( _file, b );
  end;

function TBlockDrive.BlockCount : cardinal;
  begin
    result := filesize( _file )
  end;

function TBlockDrive.ByteCount : cardinal;
  begin
    result := self.BlockCount * sizeOf( TBlock );
  end;

destructor TBlockDrive.Destroy;
  begin
    close( _file );
  end;

begin
  FillDWord( empty_block, 256, 0 );
end.
