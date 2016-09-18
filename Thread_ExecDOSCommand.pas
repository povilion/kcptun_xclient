unit Thread_ExecDOSCommand;

interface

//** Converted with Mida BASIC 275     http://www.midaconverter.com



uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,

  System.SyncObjs,

  Data.DB,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Grid,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Bind.DBEngExt,
  FMX.Bind.Editors,
  FMX.Bind.DBLinks,
  FMX.Bind.Navigator,
  Data.Bind.EngExt,
  Data.Bind.Components,
  Data.Bind.DBScope,
  Data.Bind.DBLinks,
  Datasnap.DBClient,
  Fmx.Bind.Grid,
  System.Rtti,
  System.Bindings.Outputs,
  Data.Bind.Grid,
  Fmx.StdCtrls,
  FMX.Header,
  FMX.Graphics;

//**   Original VCL Uses section : 


//**   Classes, Windows, Messages, SysUtils, ExtCtrls, StdCtrls, Forms, System.SyncObjs;

type
  TArg<T> = reference to procedure(const Arg: T);

type
  TExecDOSCommand_Thread = class(TThread)
  private
    FThreadState: Integer;      //�߳�����״̬

    FOwner: TObject;            //�����ߣ�������TClientNode����
    FMainFormHandle: TWindowHandle;   //�����ھ��

    FLock: TCriticalSection;    //������
    FCMDLog: string;            //�����������־
    FReadFromPipeStr: string;   //�ӿ���̨�ܵ��ж������ַ���
    FCommandLine: string;       //��ִ�е�������
    FCMDHandle: THandle;        //����̨������
    FMemo_Log: TMemo;
    FCorrectQuit: Boolean;      //�Ƿ����������˳�

    procedure SetMemo_log(const Value: TMemo);

    procedure InputToMemo;
    procedure CaptureConsoleOutput(const ACommand, AParameters: string; CallBack: TArg<PAnsiChar>);
    procedure AppendOutputToLog(AppendStr: string);
  protected
    procedure Execute; override;
  public
    property ThreadState: Integer read FThreadState;
    property Owner: TObject read FOwner write FOwner;
    property MainFormHandle: TWindowHandle read FMainFormHandle write FMainFormHandle;
    property CMDHandle: THandle read FCMDHandle;
    property Memo_Log: TMemo read FMemo_Log write SetMemo_log;
    property CorrectQuit: Boolean read FCorrectQuit write FCorrectQuit;

    constructor Create(CommandLine: string; CreateSuspended: Boolean);
    destructor Destroy; override;

    function GetWholeLog: string;
  end;

const
  MaxCommandLen = 8191;

implementation

uses
  PublicVar;

{ TExecDOSCommand_Thread }

procedure TExecDOSCommand_Thread.SetMemo_log(const Value: TMemo);
begin
  FLock.Acquire;
  try
    try
      FMemo_Log:= Value;
    except
      ;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TExecDOSCommand_Thread.InputToMemo;
begin
  if (FMemo_Log = nil) then
    Exit;
  FMemo_Log.Lines.Text:= FMemo_Log.Lines.Text + FReadFromPipeStr;
  FMemo_Log.SelStart:= Length(FMemo_Log.Lines.Text);
//  SendMessage(FMemo_Log.Handle, WM_VSCROLL, MAKELONG(SB_BOTTOM, 0), 0);
end;

procedure TExecDOSCommand_Thread.CaptureConsoleOutput(const ACommand, AParameters: string; CallBack: TArg<PAnsiChar>);
const
//  CReadBuffer = 2400;
  CReadBuffer = 115200;
//var
//  saSecurity: TSecurityAttributes;
//  hRead: THandle;
//  hWrite: THandle;
//  suiStartup: TStartupInfo;
//  piProcess: TProcessInformation;
//  pBuffer: array [0 .. CReadBuffer] of AnsiChar;
//  dBuffer: array [0 .. CReadBuffer] of AnsiChar;
//  dRead: DWORD;
//  dRunning: DWORD;
//  dAvailable: DWORD;
begin
//  saSecurity.nLength:= SizeOf(TSecurityAttributes);
//  saSecurity.bInheritHandle:= true;
//  saSecurity.lpSecurityDescriptor:= nil;
//  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
//    try
//      FillChar(suiStartup, SizeOf(TStartupInfo), #0);
//      suiStartup.cb:= SizeOf(TStartupInfo);
//      suiStartup.hStdInput:= hRead;
//      suiStartup.hStdOutput:= hWrite;
//      suiStartup.hStdError:= hWrite;
//      suiStartup.dwFlags:= STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
//      suiStartup.wShowWindow:= SW_HIDE;
//      if CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity, @saSecurity, true, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess) then
//        try
//          FCMDHandle:= piProcess.hProcess;
//          repeat
//            dRunning:= WaitForSingleObject(piProcess.hProcess, 100);
//            PeekNamedPipe(hRead, nil, 0, nil, @dAvailable, nil);
//            if (dAvailable > 0) then
//              repeat
//                dRead:= 0;
//                ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
//                pBuffer[dRead]:= #0;
//                OemToCharA(pBuffer, dBuffer);
//                CallBack(dBuffer);
//              until (dRead < CReadBuffer);
//            Application.ProcessMessages;
//          until (dRunning <> WAIT_TIMEOUT);
//        finally
//          CloseHandle(piProcess.hProcess);
//          CloseHandle(piProcess.hThread);
//        end;//try
//    finally
//      CloseHandle(hRead);
//      CloseHandle(hWrite);
//    end;//try
end;

procedure TExecDOSCommand_Thread.AppendOutputToLog(AppendStr: string);
begin
  FLock.Acquire;
  try
    try
      FCMDLog:= FCMDLog + AppendStr;
    except
      ;
    end;
  finally
    FLock.Release;
  end;
end;

function TExecDOSCommand_Thread.GetWholeLog: string;
begin
  FLock.Acquire;
  try
    Result:= FCMDLog;
  finally
    FLock.Release;
  end;
end;

constructor TExecDOSCommand_Thread.Create(CommandLine: string; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);

  FLock:= TCriticalSection.Create;
  FCMDLog:= '';
  FMemo_Log:= nil;
  FCorrectQuit:= False;
  FCommandLine:= CommandLine;
  FThreadState:= 0;
end;

destructor TExecDOSCommand_Thread.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TExecDOSCommand_Thread.Execute;
begin
  FThreadState:= 1;
  FCorrectQuit:= False;
  try
    FReadFromPipeStr:= 'ִ�����' + FCommandLine + #13 + #10;
    AppendOutputToLog(FReadFromPipeStr);
    Synchronize(InputToMemo);
    if Length(FCommandLine) > MaxCommandLen then
      begin
        FReadFromPipeStr:= '�������ַ�����������������󳤶ȣ�������ֹ��' + #13 + #10;
        AppendOutputToLog(FReadFromPipeStr);
        Synchronize(InputToMemo);
      end
    else
      begin
        FReadFromPipeStr:= '*************************** begin ***************************' + #13 + #10;
        AppendOutputToLog(FReadFromPipeStr);
        Synchronize(InputToMemo);

        CaptureConsoleOutput(FCommandLine, '',
          procedure(const Line: PAnsiChar)
            begin
              FReadFromPipeStr:= string(Line);
              AppendOutputToLog(FReadFromPipeStr);
              Synchronize(InputToMemo);
            end
        );
      end;
    FReadFromPipeStr:= '**************************** end ****************************' + #13 + #10 + #13 + #10;
    AppendOutputToLog(FReadFromPipeStr);
    Synchronize(InputToMemo);

//    if (not FCorrectQuit) then
//      PostMessage(FMainFormHandle, WM_DOSCOMMANDSTOP, 0, LPARAM(FOwner));

    FThreadState:= 2;
    while not Terminated do
      begin
        Application.ProcessMessages;
        Sleep(200);
      end;
  finally
    FThreadState:= 0;
  end;//try
end;

end.