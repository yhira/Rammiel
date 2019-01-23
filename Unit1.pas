{/////////////////////////////////////////////////
OpenGLサンプル
OpenGLでラミエル（平行投影）

参考
OpenGLプログラミングコース - 株式会社エクサ 
http://www.exa-corp.co.jp/solutions/common/ubiquitous/ubiquitous-solution/
Delphi2005 プログラミングテクニック Vol.10  OpenGL編 
http://www.cutt.co.jp/book/4-87783-148-7.html
ライティングの色設定のコツ
http://sky.geocities.jp/freakish_osprey/opengl/opengl_lighting.htm
/////////////////////////////////////////////////}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, MMSystem;

type
  TForm1 = class(TForm)
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
    hdc          :HDC;      //デバイスコンテキストのハンドル
    hrc          :HGLRC;    //レンダリングコンテキストのハンドル
    nPixelFormat :Integer;  //ピクセルフォーマットのID
    listid       :Integer;  //ディスプレイ・リストのID
    mFlag        :Boolean;  //マウスボタンフラグ 
    atFlag        :Boolean;  //ATフィールドフラグ
    sx           :Integer;  //マウス移動前のx座標
    ex           :Integer;  //マウス移動後のx座標
    procedure IdleLoop(Sender: TObject; var Done: Boolean);
    procedure SetPixelFormatDescriptor;
    procedure Display;
    procedure MakeDisplayList;
    procedure SetupLighting;
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.IdleLoop(Sender: TObject; var Done: Boolean);
begin
  Display;
  SwapBuffers(hdc);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin        
  Randomize;
  //OnIdleイベント
  Application.OnIdle:= IdleLoop;

  //マウスボタンフラグの初期化
  mFlag := False;

  //クライアント領域のデバイスコンテキストの取得
  hdc := GetDC(Handle);

  //ピクセルフォーマットの初期設定
  SetPixelFormatDescriptor;

  //レンダリングコンテキストのハンドルを取得
  hrc := wglCreateContext(hdc);
  if (hrc = NULL) then ShowMessage('Could not CreateContext');

  //カレントコンテキストの設定
  if not (wglMakeCurrent(hdc, hrc)) then
    ShowMessage('Could not MakeCurrent');

  //背景色を黒にする
  glClearColor(0, 0, 0, 1);

  //隠面消去を有効にする
  glEnable(GL_DEPTH_TEST);

  //法線ベクトルの自動正規化
//  glEnable( GL_NORMALIZE );

  //ライトの設定
  SetupLighting;
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  // ディスプレイ・リストの作成
  MakeDisplayList;
end;

// ピクセルフォーマットの初期設定
procedure TForm1.SetPixelFormatDescriptor;
var
  pfd :TPixelFormatDescriptor;
begin
  with pfd do begin
    nSize:=           sizeof(TPixelFormatDescriptor);
    nVersion:=        1;
    dwFlags:=         PFD_DRAW_TO_WINDOW or
                      PFD_SUPPORT_OPENGL or
                      PFD_DOUBLEBUFFER;
    iPixelType:=      PFD_TYPE_RGBA;
    cColorBits:=      24;
    cRedBits:=        0;
    cRedShift:=       0;
    cGreenBits:=      0;
    cGreenShift:=     0;
    cBlueBits:=       0;
    cBlueShift:=      0;
    cAlphaBits:=      0;
    cAlphaShift:=     0;
    cAccumBits:=      0;
    cAccumRedBits:=   0;
    cAccumGreenBits:= 0;
    cAccumBlueBits:=  0;
    cAccumAlphaBits:= 0;
    cDepthBits:=      32;
    cStencilBits:=    0;
    cAuxBuffers:=     0;
    iLayerType:=      PFD_MAIN_PLANE;
    bReserved:=       0;
    dwLayerMask:=     0;
    dwVisibleMask:=   0;
    dwDamageMask:=    0;
  end;

  nPixelFormat := ChoosePixelFormat(hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd);
end;

procedure TForm1.FormResize(Sender: TObject);
var
  w, h   :GLint;    //クライアント領域の幅・高さ
  nRange :GLfloat;  //座標系の単位
begin
  //座標系の単位
  nRange := 2.2;

  //クライアント領域の幅
  w := ClientWidth;

  //クライアント領域の高さ
  h := ClientHeight;
  if h = 0 then ClientHeight := 1;

  //ビューポートの設定
  glViewport(0, 0, w, h);

  //投影変換モード
  glMatrixMode(GL_PROJECTION);

  //行列を初期化
  glLoadIdentity();

  //平行投影
  if (w>h) then begin
    glOrtho(-nRange*(w/h),nRange*(w/h),-nRange,nRange,-nRange,nRange);
  end else begin
    glOrtho(-nRange,nRange,-nRange*(h/w),nRange*(h/w),-nRange,nRange);
  end;

//  //透視投影
//  gluPerspective(70, w/h, 1, 10);
//  //ビューイングマトリックスの設定
//  gluLookAt(0, 0, 3.5,
//    0, 0, 0,
//    0, 1, 0);

  //モデルビュー変換モード
  glMatrixMode(GL_MODELVIEW);

  //行列を初期化
  glLoadIdentity();
  //Y軸を30度回転
  glRotatef(30, 0, 1, 0);
end;

// オブジェクトの描画
procedure TForm1.Display;
const
  //オブジェクトの材質（青色・光沢あり）
  materialAmbient  : array[0..3] of GLFloat = (0.0, 0.0, 0.3, 1.0);  //環境光
  materialDiffuse  : array[0..3] of GLFloat = (0.0, 0.0, 1.0, 1.0);  //拡散光
  materialSpecular : array[0..3] of GLFloat = (0.8, 0.8, 0.8, 1.0);  //鏡面光
  materialShininess: array[0..0] of GLFloat = (60.0); //鏡面係数
  //ATフィールド
  rmaterialAmbient  : array[0..3] of GLFloat = (0.5, 0.0, 0.0, 1.0);  //環境光
  rmaterialDiffuse  : array[0..3] of GLFloat = (1.0, 0.0, 0.0, 1.0);  //拡散光
var i, r: Integer; n: Single;
begin
  //ウィンドウの背景とデプスバッファをクリア
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);


  glPushMatrix();
  //材質の設定
  glMaterialfv(GL_FRONT, GL_AMBIENT  ,@materialAmbient);
  glMaterialfv(GL_FRONT, GL_DIFFUSE  ,@materialDiffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR ,@materialSpecular);
  glMaterialfv(GL_FRONT, GL_SHININESS,@materialShininess);
  //ディスプレイ・リストを使って描画
  glCallList(listid);
  glPopMatrix();

  if atFlag then begin
    //ATフィールド描画
    glPushMatrix();
    //材質の設定
    glMaterialfv(GL_FRONT,GL_AMBIENT  ,@rmaterialAmbient);
    glMaterialfv(GL_FRONT,GL_DIFFUSE  ,@rmaterialDiffuse);
    glRotatef(45, 0, 1, 0);
    glTranslate(0, 0, 0.6);
    for i := 1 to 7 do begin
      n := i;
      r := Random(10);
      if (r mod 2) = 0 then n := n + r/100;
      glNormal3f(0, 0, 1);
      glBegin(GL_LINE_LOOP);
        glVertex3f( 0,  0.2*n, 1);
        glVertex3f(-0.2*n,  0.1*n, 1);
        glVertex3f(-0.2*n, -0.1*n, 1);
        glVertex3f( 0, -0.2*n, 1);
        glVertex3f( 0.2*n, -0.1*n, 1);
        glVertex3f( 0.2*n,  0.1*n, 1);
      glEnd;
    end;
    glPopMatrix();
  end;     

  //OpenGLのコマンドを強制的に実行
  glFlush;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle,hdc);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //左ボタンを押したとき
  if (Button = mbLeft) then begin
    //回転モードをオンにする
    mFlag:=true;

    //移動前のx座標を保持
    sx := X;

    //ラミエル音再生
    PlaySound(PChar('rammi.wav'), 0, SND_FILENAME or SND_ASYNC);
  end;
  //右ボタンを押したとき
  if (Button = mbRight) then
    atFlag := not atFlag; //ATフィールドの切り替え
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //回転モードの確認
  if(mFlag=true) then begin
    //移動時のx座標を保持
    ex := X;

    //X軸方向の移動量の差分を使って、Y軸まわりに回転
    glRotatef((ex-sx), 0, 1, 0);  
    //x座標を更新
    sx := ex;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //回転モードをオフにする
  mFlag := false;
end;

// ディスプレイ・リストの作成
procedure TForm1.MakeDisplayList;
var
  myObject :GLUquadricObj;  //GLUオブジェクト
begin
  //新しいGLUオブジェクトを作成する
  myObject := gluNewQuadric;

  //GLUオブジェクトの描画スタイル
  gluQuadricDrawStyle(myObject, GLU_FILL);
  //ディスプレイ・リストのIDを取得
  listid := glGenLists(1);

  //ディスプレイ・リストの作成（ラミエル）
  glNewList(listid, GL_COMPILE);

    ////前面上
    glNormal3f(0, 0.5, 1);
    glBegin(GL_POLYGON);  
      glVertex3f( 0, 1.2, 0);
      glVertex3f( 1, 0, 1);
      glVertex3f(-1, 0, 1);
    glEnd;

    ////前面下
    glNormal3f(0, -0.5, 1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2, 0);
      glVertex3f( 1,  0, 1);
      glVertex3f(-1,  0, 1);
    glEnd;
    
    //後面上
    glNormal3f(0 ,0.5, -1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f( 1, 0, -1);
      glVertex3f(-1, 0, -1);
    glEnd;
    
    //後面下
    glNormal3f(0 ,-0.5, -1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f( 1,  0, -1);
      glVertex3f(-1,  0, -1);
    glEnd;

    //左側面上
    glNormal3f(-1, 0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f(-1, 0, -1);
      glVertex3f(-1, 0,  1);
    glEnd;
    
    //左側面下
    glNormal3f(-1, -0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f(-1,  0, -1);
      glVertex3f(-1,  0,  1);
    glEnd;
    
    //右側面上
    glNormal3f(1, 0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f( 1, 0, -1);
      glVertex3f( 1, 0,  1);
    glEnd;
    
    //右側面下
    glNormal3f(1, -0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f( 1,  0, -1);
      glVertex3f( 1,  0,  1);
    glEnd;
  glEndList;
end;

// ライトの設定
procedure TForm1.SetupLighting;
const
  //ライト0の定義
  ambient0 : array[0..3] of GLFloat = (0.9, 0.9, 0.9, 1.0);  //環境光
  diffuse0 : array[0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);  //拡散光
  specular0: array[0..3] of GLFloat = (0.8, 0.8, 0.8, 1.0);  //鏡面光
  position0: array[0..3] of GLFloat = (1, 1, 1, 0);   //位置（無限遠）
begin
  //ライト0の設定
  glLightfv(GL_LIGHT0, GL_AMBIENT,  @ambient0);
  glLightfv(GL_LIGHT0, GL_DIFFUSE,  @diffuse0);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @specular0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position0);
end;

end.
