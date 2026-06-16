// launcher.jsx — "잘보이네" 어르신용 런처 홈화면 (4가지 개선안)
// 잘보이네 브랜드: 따뜻한 크림 배경, 장파장 색, Pretendard, 점토(클레이) 질감.
// 색 구분은 유지하되 톤을 맞춰 고급스럽게. 큰 글씨·큰 터치영역·상시 SOS.
// exports(window): GridHome, PeopleHome, ListHome, VoiceHome

const LF = "'Pretendard','Pretendard Variable',-apple-system,system-ui,sans-serif";

// ── 아이콘 (단순 UI 글리프, 흰색) ─────────────────────────────
const Ic = {
  phone: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C10.6 21 3 13.4 3 4c0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.2.2 2.4.6 3.6.1.4 0 .8-.3 1l-2.1 2.2z"/>
    </svg>
  ),
  chat: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <path d="M4 4h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H9l-5 4v-4a2 2 0 0 1-1-1.7V6a2 2 0 0 1 2-2z"/>
    </svg>
  ),
  chatDots: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <path d="M4 4h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H9l-5 4v-4a2 2 0 0 1-1-1.7V6a2 2 0 0 1 2-2z"/>
      <circle cx="8.5" cy="10.5" r="1.5" fill="#E8A93B"/>
      <circle cx="13" cy="10.5" r="1.5" fill="#E8A93B"/>
      <circle cx="17.5" cy="10.5" r="1.5" fill="#E8A93B"/>
    </svg>
  ),
  play: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="2.5" y="5" width="19" height="14" rx="4.5" fill="#fff"/>
      <path d="M10 9.2l5 2.8-5 2.8z" fill="#D8431C"/>
    </svg>
  ),
  camera: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <path d="M9 4h6l1.4 2H20a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h3.6L9 4z"/>
      <circle cx="12" cy="13" r="3.6" fill="#7E55B0"/>
      <circle cx="12" cy="13" r="1.5" fill="#fff"/>
    </svg>
  ),
  photo: (s = 48) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <rect x="3" y="5" width="18" height="14" rx="3"/>
      <circle cx="8.5" cy="10" r="1.8" fill="#C85E94"/>
      <path d="M6 17l4-4 3 3 3-3 3 3v1H6z" fill="#C85E94"/>
    </svg>
  ),
  bell: (s = 30) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <path d="M12 3a6 6 0 0 0-6 6c0 4-1.5 5.5-2 6.5h16c-.5-1-2-2.5-2-6.5a6 6 0 0 0-6-6z"/>
      <path d="M10 19a2 2 0 0 0 4 0z"/>
    </svg>
  ),
  sun: (s = 30) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke="#F2A93B" strokeWidth="2" strokeLinecap="round">
      <circle cx="12" cy="12" r="4.2" fill="#FFC766" stroke="none"/>
      <path d="M12 2.5v2.4M12 19.1v2.4M2.5 12h2.4M19.1 12h2.4M5.2 5.2l1.7 1.7M17.1 17.1l1.7 1.7M18.8 5.2l-1.7 1.7M6.9 17.1l-1.7 1.7"/>
    </svg>
  ),
  mic: (s = 56) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="#fff">
      <rect x="9" y="2.5" width="6" height="11" rx="3"/>
      <path d="M5.5 11a6.5 6.5 0 0 0 13 0" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
      <path d="M12 17.5V21" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  chevron: (s = 26) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 5l7 7-7 7"/>
    </svg>
  ),
};

// 앱 색상 — 색 구분 유지, 톤은 통일(채도/명도 정렬)
const APPS = {
  phone:   { label: '전화',     icon: 'phone',    c1: '#6FB36A', c2: '#4E9457', sh: 'rgba(60,120,60,0.42)' },
  message: { label: '메시지',   icon: 'chat',     c1: '#5E96D6', c2: '#4374B8', sh: 'rgba(50,95,165,0.42)' },
  kakao:   { label: '카카오톡', icon: 'chatDots', c1: '#FFCE5C', c2: '#F2A93B', sh: 'rgba(210,150,40,0.45)' },
  youtube: { label: '유튜브',   icon: 'play',     c1: '#F2683E', c2: '#D8431C', sh: 'rgba(200,60,25,0.42)' },
  camera:  { label: '카메라',   icon: 'camera',   c1: '#A074C8', c2: '#7E55B0', sh: 'rgba(110,70,160,0.42)' },
  gallery: { label: '갤러리',   icon: 'photo',    c1: '#E07AAC', c2: '#C85E94', sh: 'rgba(180,75,130,0.42)' },
};

const PAGE_BG = 'linear-gradient(180deg,#FDF7EE 0%,#F6EBDA 100%)';
const INK = '#3A2410';
const INK_SOFT = '#7A5A40';

// ── 점토 질감 타일 ────────────────────────────────────────────
function clayStyle(a, r = 30) {
  return {
    background: `linear-gradient(160deg, ${a.c1} 0%, ${a.c2} 100%)`,
    borderRadius: r,
    boxShadow: `inset 0 3px 4px rgba(255,255,255,0.45), inset 0 -7px 12px rgba(0,0,0,0.16), 0 12px 20px ${a.sh}`,
    border: 'none', cursor: 'pointer',
  };
}
const labelShadow = '0 2px 3px rgba(0,0,0,0.25)';

// ── 공통 셸 ───────────────────────────────────────────────────
function Page({ children, pad = '92px 22px 30px' }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: PAGE_BG, fontFamily: LF, color: INK,
      padding: pad, boxSizing: 'border-box', display: 'flex', flexDirection: 'column',
      WebkitFontSmoothing: 'antialiased',
    }}>{children}</div>
  );
}

function Header({ greet = '좋은 오후예요, 할머니', big = true }) {
  return (
    <div style={{ flexShrink: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
        <span style={{ fontSize: 16, fontWeight: 700, color: INK_SOFT, letterSpacing: -0.3, whiteSpace: 'nowrap' }}>5월 18일 토요일</span>
        <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 16, fontWeight: 700, color: INK_SOFT, whiteSpace: 'nowrap' }}>
          {Ic.sun(20)} 맑음 23°C
        </span>
      </div>
      <h1 style={{ margin: big ? '8px 0 18px' : '6px 0 12px', fontSize: big ? 31 : 26, fontWeight: 800, letterSpacing: -1, color: INK }}>
        {greet}
      </h1>
    </div>
  );
}

function SOS({ style }) {
  return (
    <button style={{
      flexShrink: 0, width: '100%', height: 76, marginTop: 'auto', border: 'none', borderRadius: 24, cursor: 'pointer',
      background: 'linear-gradient(160deg,#F25441,#D62116)',
      boxShadow: 'inset 0 3px 4px rgba(255,255,255,0.4), inset 0 -6px 10px rgba(0,0,0,0.2), 0 12px 22px rgba(200,30,20,0.45)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 14, ...style,
    }}>
      <span style={{
        width: 44, height: 44, borderRadius: '50%', border: '2.5px solid #fff', color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 800, letterSpacing: 0.5,
      }}>SOS</span>
      <span style={{ fontSize: 28, fontWeight: 800, color: '#fff', letterSpacing: -0.5, textShadow: labelShadow }}>긴급 구조 요청</span>
      {Ic.bell(28)}
    </button>
  );
}

// 큰 격자 타일
function GridTile({ app, h = 152 }) {
  return (
    <button style={{ ...clayStyle(app), height: h, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 0 }}>
      {Ic[app.icon](50)}
      <span style={{ fontSize: 27, fontWeight: 800, color: '#fff', letterSpacing: -0.6, textShadow: labelShadow }}>{app.label}</span>
    </button>
  );
}

// ════════════════════════════════════════════════════════════
// 1 · 큰 격자 (레퍼런스 정제판) — 익숙함 유지, 톤·질감 고급화
// ════════════════════════════════════════════════════════════
function GridHome() {
  const order = ['phone', 'message', 'kakao', 'youtube', 'camera', 'gallery'];
  return (
    <Page>
      <Header />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, marginBottom: 16 }}>
        {order.map((k) => <GridTile key={k} app={APPS[k]} />)}
      </div>
      <SOS />
    </Page>
  );
}

// ════════════════════════════════════════════════════════════
// 2 · 사람 먼저 — 가족 얼굴 눌러 바로 전화. 추상 앱보다 직관적
// ════════════════════════════════════════════════════════════
function Avatar({ name, rel, c1, c2 }) {
  return (
    <button style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 9, flex: 1 }}>
      <div style={{
        width: 86, height: 86, borderRadius: '50%',
        background: `linear-gradient(160deg, ${c1}, ${c2})`,
        boxShadow: `inset 0 3px 4px rgba(255,255,255,0.45), inset 0 -6px 10px rgba(0,0,0,0.16), 0 10px 16px rgba(120,70,40,0.28)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 38, fontWeight: 800, color: '#fff', textShadow: labelShadow,
      }}>{name[0]}</div>
      <div style={{ textAlign: 'center', lineHeight: 1.25 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: INK_SOFT }}>{rel}</div>
        <div style={{ fontSize: 19, fontWeight: 800, color: INK, letterSpacing: -0.4 }}>{name}</div>
      </div>
    </button>
  );
}
function PeopleHome() {
  const people = [
    { name: '영희', rel: '딸', c1: '#F2683E', c2: '#D8431C' },
    { name: '철수', rel: '아들', c1: '#5E96D6', c2: '#4374B8' },
    { name: '민준', rel: '손주', c1: '#6FB36A', c2: '#4E9457' },
  ];
  const quick = ['phone', 'kakao', 'youtube', 'camera'];
  return (
    <Page>
      <Header greet="좋은 오후예요, 할머니" />
      <div style={{ fontSize: 18, fontWeight: 700, color: INK_SOFT, marginBottom: 12 }}>가족에게 전화하기</div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 22 }}>
        {people.map((p) => <Avatar key={p.name} {...p} />)}
      </div>
      <div style={{ fontSize: 18, fontWeight: 700, color: INK_SOFT, marginBottom: 12 }}>자주 쓰는 앱</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, marginBottom: 16 }}>
        {quick.map((k) => <GridTile key={k} app={APPS[k]} h={120} />)}
      </div>
      <SOS />
    </Page>
  );
}

// ════════════════════════════════════════════════════════════
// 3 · 한 줄 리스트 — 위→아래로 훑기 쉬운 초대형 행. 저시력 친화
// ════════════════════════════════════════════════════════════
function ListRow({ app }) {
  return (
    <button style={{
      width: '100%', height: 86, border: 'none', cursor: 'pointer', borderRadius: 24,
      background: '#fff', boxShadow: '0 4px 14px rgba(120,80,40,0.1), inset 0 0 0 1px rgba(120,80,40,0.06)',
      display: 'flex', alignItems: 'center', gap: 18, padding: '0 18px 0 14px',
    }}>
      <span style={{ ...clayStyle(app, 20), width: 64, height: 64, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, boxShadow: `inset 0 2px 3px rgba(255,255,255,0.45), inset 0 -4px 8px rgba(0,0,0,0.16), 0 6px 12px ${app.sh}` }}>
        {Ic[app.icon](36)}
      </span>
      <span style={{ flex: 1, textAlign: 'left', fontSize: 29, fontWeight: 800, color: INK, letterSpacing: -0.6 }}>{app.label}</span>
      <span style={{ color: '#C9A98C', display: 'flex' }}>{Ic.chevron(28)}</span>
    </button>
  );
}
function ListHome() {
  const order = ['phone', 'message', 'kakao', 'youtube', 'camera', 'gallery'];
  return (
    <Page pad="92px 22px 30px">
      <Header big={false} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 16 }}>
        {order.map((k) => <ListRow key={k} app={APPS[k]} />)}
      </div>
      <SOS />
    </Page>
  );
}

// ════════════════════════════════════════════════════════════
// 4 · 음성 우선 — 마스코트에게 말로 부탁. 글·터치 부담 최소
// ════════════════════════════════════════════════════════════
function VoiceHome() {
  const Mascot = window.Mascot;
  const quick = ['phone', 'kakao', 'youtube', 'camera'];
  return (
    <Page>
      <Header greet="무엇을 도와드릴까요?" />
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 22, margin: '4px 0 22px' }}>
        {Mascot && <Mascot size={140} palette={{ core: '#FFF1C4', mid: '#FFC868', edge: '#FBA64A', glow: 'rgba(255,180,90,0.5)' }} />}
        <button style={{
          width: '100%', height: 96, border: 'none', borderRadius: 28, cursor: 'pointer',
          background: 'linear-gradient(160deg,#F2742E,#E0481C)',
          boxShadow: 'inset 0 3px 4px rgba(255,255,255,0.4), inset 0 -6px 10px rgba(0,0,0,0.18), 0 14px 24px rgba(224,72,28,0.4)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 14,
        }}>
          {Ic.mic(46)}
          <span style={{ fontSize: 26, fontWeight: 800, color: '#fff', letterSpacing: -0.5, textShadow: labelShadow }}>눌러서 말하기</span>
        </button>
        <div style={{ fontSize: 17, fontWeight: 600, color: INK_SOFT, textAlign: 'center', marginTop: -6 }}>
          "영희에게 전화해줘" 처럼 말해보세요
        </div>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 10, marginBottom: 16 }}>
        {quick.map((k) => (
          <button key={k} style={{ ...clayStyle(APPS[k], 22), height: 84, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 5, padding: 0 }}>
            {Ic[APPS[k].icon](30)}
            <span style={{ fontSize: 15, fontWeight: 700, color: '#fff', textShadow: labelShadow }}>{APPS[k].label}</span>
          </button>
        ))}
      </div>
      <SOS />
    </Page>
  );
}

Object.assign(window, { GridHome, PeopleHome, ListHome, VoiceHome });
