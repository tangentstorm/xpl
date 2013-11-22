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
  TBlock = array [ 0..1023 ] of byte;
  TBlockDrive = class
  private
    _path : string;
    _file : file of TBlock;
  public
    constructor Create;
    procedure Wipe;
    procedure Grow( n : byte );
    procedure Load( i : cardinal; var b : TBlock );
    procedure Save( i : cardinal; var b : TBlock );
    function BlockCount : cardinal;
    function ByteCount : cardinal;
    destructor Destroy;
  published
    property path : string read _path write _path;
  end;

implementation
var
  empty_block : TBlock;

constructor TBlockDrive.init ( path : string );
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

function TBlockDrive.block_count : cardinal;
  begin
    result := filesize( _file )
  end;

function TBlockDrive.byte_count : cardinal;
  begin
    result := self.block_count * sizeOf( TBlock );
  end;

destructor TBlockDrive.Destroy;
  begin
    close( _file );
  end;

begin
  FillDWord( empty_block, 256, 0 );
end.
