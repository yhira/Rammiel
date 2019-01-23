{/////////////////////////////////////////////////
OpenGL�T���v��
OpenGL�Ń��~�G���i���s���e�j

�Q�l
OpenGL�v���O���~���O�R�[�X - ������ЃG�N�T 
http://www.exa-corp.co.jp/solutions/common/ubiquitous/ubiquitous-solution/
Delphi2005 �v���O���~���O�e�N�j�b�N Vol.10  OpenGL�� 
http://www.cutt.co.jp/book/4-87783-148-7.html
���C�e�B���O�̐F�ݒ�̃R�c
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
    { Private �錾 }
    hdc          :HDC;      //�f�o�C�X�R���e�L�X�g�̃n���h��
    hrc          :HGLRC;    //�����_�����O�R���e�L�X�g�̃n���h��
    nPixelFormat :Integer;  //�s�N�Z���t�H�[�}�b�g��ID
    listid       :Integer;  //�f�B�X�v���C�E���X�g��ID
    mFlag        :Boolean;  //�}�E�X�{�^���t���O 
    atFlag        :Boolean;  //AT�t�B�[���h�t���O
    sx           :Integer;  //�}�E�X�ړ��O��x���W
    ex           :Integer;  //�}�E�X�ړ����x���W
    procedure IdleLoop(Sender: TObject; var Done: Boolean);
    procedure SetPixelFormatDescriptor;
    procedure Display;
    procedure MakeDisplayList;
    procedure SetupLighting;
  public
    { Public �錾 }
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
  //OnIdle�C�x���g
  Application.OnIdle:= IdleLoop;

  //�}�E�X�{�^���t���O�̏�����
  mFlag := False;

  //�N���C�A���g�̈�̃f�o�C�X�R���e�L�X�g�̎擾
  hdc := GetDC(Handle);

  //�s�N�Z���t�H�[�}�b�g�̏����ݒ�
  SetPixelFormatDescriptor;

  //�����_�����O�R���e�L�X�g�̃n���h�����擾
  hrc := wglCreateContext(hdc);
  if (hrc = NULL) then ShowMessage('Could not CreateContext');

  //�J�����g�R���e�L�X�g�̐ݒ�
  if not (wglMakeCurrent(hdc, hrc)) then
    ShowMessage('Could not MakeCurrent');

  //�w�i�F�����ɂ���
  glClearColor(0, 0, 0, 1);

  //�B�ʏ�����L���ɂ���
  glEnable(GL_DEPTH_TEST);

  //�@���x�N�g���̎������K��
//  glEnable( GL_NORMALIZE );

  //���C�g�̐ݒ�
  SetupLighting;
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  // �f�B�X�v���C�E���X�g�̍쐬
  MakeDisplayList;
end;

// �s�N�Z���t�H�[�}�b�g�̏����ݒ�
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
  w, h   :GLint;    //�N���C�A���g�̈�̕��E����
  nRange :GLfloat;  //���W�n�̒P��
begin
  //���W�n�̒P��
  nRange := 2.2;

  //�N���C�A���g�̈�̕�
  w := ClientWidth;

  //�N���C�A���g�̈�̍���
  h := ClientHeight;
  if h = 0 then ClientHeight := 1;

  //�r���[�|�[�g�̐ݒ�
  glViewport(0, 0, w, h);

  //���e�ϊ����[�h
  glMatrixMode(GL_PROJECTION);

  //�s���������
  glLoadIdentity();

  //���s���e
  if (w>h) then begin
    glOrtho(-nRange*(w/h),nRange*(w/h),-nRange,nRange,-nRange,nRange);
  end else begin
    glOrtho(-nRange,nRange,-nRange*(h/w),nRange*(h/w),-nRange,nRange);
  end;

//  //�������e
//  gluPerspective(70, w/h, 1, 10);
//  //�r���[�C���O�}�g���b�N�X�̐ݒ�
//  gluLookAt(0, 0, 3.5,
//    0, 0, 0,
//    0, 1, 0);

  //���f���r���[�ϊ����[�h
  glMatrixMode(GL_MODELVIEW);

  //�s���������
  glLoadIdentity();
  //Y����30�x��]
  glRotatef(30, 0, 1, 0);
end;

// �I�u�W�F�N�g�̕`��
procedure TForm1.Display;
const
  //�I�u�W�F�N�g�̍ގ��i�F�E���򂠂�j
  materialAmbient  : array[0..3] of GLFloat = (0.0, 0.0, 0.3, 1.0);  //����
  materialDiffuse  : array[0..3] of GLFloat = (0.0, 0.0, 1.0, 1.0);  //�g�U��
  materialSpecular : array[0..3] of GLFloat = (0.8, 0.8, 0.8, 1.0);  //���ʌ�
  materialShininess: array[0..0] of GLFloat = (60.0); //���ʌW��
  //AT�t�B�[���h
  rmaterialAmbient  : array[0..3] of GLFloat = (0.5, 0.0, 0.0, 1.0);  //����
  rmaterialDiffuse  : array[0..3] of GLFloat = (1.0, 0.0, 0.0, 1.0);  //�g�U��
var i, r: Integer; n: Single;
begin
  //�E�B���h�E�̔w�i�ƃf�v�X�o�b�t�@���N���A
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);


  glPushMatrix();
  //�ގ��̐ݒ�
  glMaterialfv(GL_FRONT, GL_AMBIENT  ,@materialAmbient);
  glMaterialfv(GL_FRONT, GL_DIFFUSE  ,@materialDiffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR ,@materialSpecular);
  glMaterialfv(GL_FRONT, GL_SHININESS,@materialShininess);
  //�f�B�X�v���C�E���X�g���g���ĕ`��
  glCallList(listid);
  glPopMatrix();

  if atFlag then begin
    //AT�t�B�[���h�`��
    glPushMatrix();
    //�ގ��̐ݒ�
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

  //OpenGL�̃R�}���h�������I�Ɏ��s
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
  //���{�^�����������Ƃ�
  if (Button = mbLeft) then begin
    //��]���[�h���I���ɂ���
    mFlag:=true;

    //�ړ��O��x���W��ێ�
    sx := X;

    //���~�G�����Đ�
    PlaySound(PChar('rammi.wav'), 0, SND_FILENAME or SND_ASYNC);
  end;
  //�E�{�^�����������Ƃ�
  if (Button = mbRight) then
    atFlag := not atFlag; //AT�t�B�[���h�̐؂�ւ�
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //��]���[�h�̊m�F
  if(mFlag=true) then begin
    //�ړ�����x���W��ێ�
    ex := X;

    //X�������̈ړ��ʂ̍������g���āAY���܂��ɉ�]
    glRotatef((ex-sx), 0, 1, 0);  
    //x���W���X�V
    sx := ex;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //��]���[�h���I�t�ɂ���
  mFlag := false;
end;

// �f�B�X�v���C�E���X�g�̍쐬
procedure TForm1.MakeDisplayList;
var
  myObject :GLUquadricObj;  //GLU�I�u�W�F�N�g
begin
  //�V����GLU�I�u�W�F�N�g���쐬����
  myObject := gluNewQuadric;

  //GLU�I�u�W�F�N�g�̕`��X�^�C��
  gluQuadricDrawStyle(myObject, GLU_FILL);
  //�f�B�X�v���C�E���X�g��ID���擾
  listid := glGenLists(1);

  //�f�B�X�v���C�E���X�g�̍쐬�i���~�G���j
  glNewList(listid, GL_COMPILE);

    ////�O�ʏ�
    glNormal3f(0, 0.5, 1);
    glBegin(GL_POLYGON);  
      glVertex3f( 0, 1.2, 0);
      glVertex3f( 1, 0, 1);
      glVertex3f(-1, 0, 1);
    glEnd;

    ////�O�ʉ�
    glNormal3f(0, -0.5, 1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2, 0);
      glVertex3f( 1,  0, 1);
      glVertex3f(-1,  0, 1);
    glEnd;
    
    //��ʏ�
    glNormal3f(0 ,0.5, -1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f( 1, 0, -1);
      glVertex3f(-1, 0, -1);
    glEnd;
    
    //��ʉ�
    glNormal3f(0 ,-0.5, -1);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f( 1,  0, -1);
      glVertex3f(-1,  0, -1);
    glEnd;

    //�����ʏ�
    glNormal3f(-1, 0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f(-1, 0, -1);
      glVertex3f(-1, 0,  1);
    glEnd;
    
    //�����ʉ�
    glNormal3f(-1, -0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f(-1,  0, -1);
      glVertex3f(-1,  0,  1);
    glEnd;
    
    //�E���ʏ�
    glNormal3f(1, 0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, 1.2,  0);
      glVertex3f( 1, 0, -1);
      glVertex3f( 1, 0,  1);
    glEnd;
    
    //�E���ʉ�
    glNormal3f(1, -0.5, 0);
    glBegin(GL_POLYGON);
      glVertex3f( 0, -1.2,  0);
      glVertex3f( 1,  0, -1);
      glVertex3f( 1,  0,  1);
    glEnd;
  glEndList;
end;

// ���C�g�̐ݒ�
procedure TForm1.SetupLighting;
const
  //���C�g0�̒�`
  ambient0 : array[0..3] of GLFloat = (0.9, 0.9, 0.9, 1.0);  //����
  diffuse0 : array[0..3] of GLFloat = (1.0, 1.0, 1.0, 1.0);  //�g�U��
  specular0: array[0..3] of GLFloat = (0.8, 0.8, 0.8, 1.0);  //���ʌ�
  position0: array[0..3] of GLFloat = (1, 1, 1, 0);   //�ʒu�i�������j
begin
  //���C�g0�̐ݒ�
  glLightfv(GL_LIGHT0, GL_AMBIENT,  @ambient0);
  glLightfv(GL_LIGHT0, GL_DIFFUSE,  @diffuse0);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @specular0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position0);
end;

end.
