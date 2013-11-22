{
| storage device
|
| -------------------------------------------------
| copyright (c) 2012,2013 michal j. wallace
| see LICENSE.org for usage information
}
{$mode objfpc}{$i xpc.inc}
unit sd;

interface uses log, fs, sysutils;

type
  TBlock = array [ 0..1023 ] of byte;
  TDrive = class
    constructor init ( path : string );
    procedure wipe;
    procedure grow ( n : byte );
    procedure load ( i : cardinal; var b : TBlock );
    procedure save ( i : cardinal; var b : TBlock );
    function block_count : cardinal;
    function byte_count : cardinal;
    destructor done ( );
  private
    mFile : file of TBlock;
  end;

var
  main : TDrive;

implementation
var
  empty_block : TBlock;

constructor TDrive.init ( path : string );
  begin
    // change to fs.open when it's ready
    fs.update( mFile, path );
  end;

procedure TDrive.wipe;
  begin
    seek( mFile, 0 );
    truncate( mFile );
  end;

procedure TDrive.grow ( n : byte );
  begin
    seek( mFile, filesize( mfile ));
    for n := n downto 1 do write( mFile, empty_block );
  end;

procedure TDrive.load ( i : cardinal; var b : TBlock );
  begin
    seek( mFile, i );
    read( mFile, b );
  end;

procedure TDrive.save ( i : cardinal; var b : TBlock );
  begin
    seek( mFile, i );
    write( mFile, b );
  end;

function TDrive.block_count : cardinal;
  begin
    result := filesize( mFile )
  end;

function TDrive.byte_count : cardinal;
  begin
    result := self.block_count * sizeOf( TBlock );
  end;

destructor TDrive.done;
  begin
    close( mfile );
  end;

begin
  FillDWord( empty_block, 256, 0 );
end.
