// splash.jsx — "잘보이네" 어르신용 스마트폰 온보딩 스플래시
// 세 시안: A 햇살 / B 노을 / C 단정. 모두 장파장(코랄·주황·노랑) 따뜻한 색감.
// 공통 콘텐츠: 워드마크, "어르신을 위한 쉬운 스마트폰", 시작하기(여기를 눌러보세요),
// 가족/도우미 보조 링크. 큰 글씨·높은 대비·넉넉한 버튼으로 가독성 우선.
// exports(window): Mascot, SplashA, SplashB, SplashC

// ── keyframes + 폰트 (1회 주입) ───────────────────────────────
if (typeof document !== 'undefined' && !document.getElementById('jbn-style')) {
  const s = document.createElement('style');
  s.id = 'jbn-style';
  s.textContent = `
  @import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css');
  @keyframes jbn-breathe { 0%,100%{ transform: translateY(0) scale(1);} 50%{ transform: translateY(-7px) scale(1.018);} }
  @keyframes jbn-glow   { 0%,100%{ opacity:.78; transform:scale(1);} 50%{ opacity:1; transform:scale(1.06);} }
  @keyframes jbn-ring   { 0%{ transform:scale(1); opacity:.55;} 70%{ transform:scale(1.14); opacity:0;} 100%{opacity:0;} }
  @keyframes jbn-press  { 0%,100%{ transform: translateY(0);} 50%{ transform: translateY(2px);} }
  @media (prefers-reduced-motion: reduce){
    .jbn-breathe,.jbn-glow,.jbn-ring{ animation:none !important; }
  }`;
  document.head.appendChild(s);
}

const JBN_FONT = "'Pretendard','Pretendard Variable',-apple-system,system-ui,sans-serif";

// ── 마스코트: 따뜻하고 친근한 동그란 햇살 ─────────────────────
// 둥근 눈 + 볼터치 + 환한 미소. 부드러운 노랑·살구톤.
// palette: { core(밝은 중심), mid, edge(가장자리), glow }
function Mascot({ size = 190, palette, float = true }) {
  const p = palette || {
    core: '#FFF3CC', mid: '#FFD06A', edge: '#FFA94D', glow: 'rgba(255,180,90,0.5)',
  };
  const eye = '#6B3A1A';          // 따뜻한 갈색 눈
  const eyeR = size * 0.062;
  const eyeGap = size * 0.27;     // 눈 사이 간격(센터 기준 ±)
  const eyeTop = size * 0.42;
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      {/* glow halo */}
      <div className="jbn-glow" style={{
        position: 'absolute', inset: -size * 0.34, borderRadius: '50%',
        background: `radial-gradient(circle at 50% 50%, ${p.glow} 0%, rgba(0,0,0,0) 68%)`,
        filter: 'blur(6px)', animation: float ? 'jbn-glow 4.6s ease-in-out infinite' : 'none', zIndex: 0,
      }} />
      {/* orb */}
      <div className="jbn-breathe" style={{
        position: 'absolute', inset: 0, borderRadius: '50%', zIndex: 1,
        background: `radial-gradient(circle at 38% 30%, ${p.core} 0%, ${p.mid} 46%, ${p.edge} 100%)`,
        boxShadow: `inset 0 -${size*0.06}px ${size*0.16}px rgba(214,120,40,0.4), inset 0 ${size*0.06}px ${size*0.12}px rgba(255,255,255,0.6), 0 ${size*0.12}px ${size*0.2}px rgba(214,120,40,0.34)`,
        animation: float ? 'jbn-breathe 5.2s ease-in-out infinite' : 'none',
      }}>
        {/* top sheen */}
        <div style={{
          position: 'absolute', top: '10%', left: '20%', width: '48%', height: '32%', borderRadius: '50%',
          background: 'radial-gradient(circle at 40% 40%, rgba(255,255,255,0.9), rgba(255,255,255,0) 70%)',
          filter: 'blur(2px)', pointerEvents: 'none',
        }} />
        {/* 볼터치 */}
        {[-1, 1].map((s) => (
          <div key={'c' + s} style={{
            position: 'absolute', top: eyeTop + eyeR * 0.9, left: `calc(50% + ${s * size * 0.345}px)`,
            transform: 'translate(-50%,-50%)', width: size * 0.13, height: size * 0.085, borderRadius: '50%',
            background: 'radial-gradient(circle, rgba(255,120,90,0.42), rgba(255,120,90,0) 72%)', zIndex: 2,
          }} />
        ))}
        {/* 둥근 눈 + 반짝임 */}
        {[-1, 1].map((s) => (
          <div key={'e' + s} style={{
            position: 'absolute', top: eyeTop, left: `calc(50% + ${s * eyeGap}px)`,
            transform: 'translate(-50%,-50%)', width: eyeR * 2, height: eyeR * 2.15, borderRadius: '50%',
            background: eye, zIndex: 3,
          }}>
            <div style={{
              position: 'absolute', top: '16%', left: '22%', width: '40%', height: '38%',
              borderRadius: '50%', background: 'rgba(255,255,255,0.95)',
            }} />
          </div>
        ))}
        {/* 환한 미소 */}
        <div style={{
          position: 'absolute', top: eyeTop + size * 0.16, left: '50%', transform: 'translateX(-50%)',
          width: size * 0.3, height: size * 0.17,
          border: `${size*0.028}px solid ${eye}`, borderTop: 'none',
          borderLeftColor: 'transparent', borderRightColor: 'transparent',
          borderRadius: `0 0 ${size}px ${size}px`, zIndex: 3,
        }} />
      </div>
    </div>
  );
}

// ── 공통 화면 셸 ──────────────────────────────────────────────
// 상태바 영역을 피해 콘텐츠를 세로로 배치. theme로 색만 교체.
function Screen({ theme, children }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: theme.bg,
      fontFamily: JBN_FONT, color: theme.ink,
      display: 'flex', flexDirection: 'column',
      padding: '96px 30px 56px', boxSizing: 'border-box',
      WebkitFontSmoothing: 'antialiased',
    }}>
      {/* 은은한 따뜻한 배경 글로우 */}
      {theme.deco}
      <div style={{ position: 'relative', zIndex: 2, display: 'flex', flexDirection: 'column', height: '100%' }}>
        {children}
      </div>
    </div>
  );
}

// 워드마크: 작은 햇살 마크 + "잘보이네"
function Wordmark({ ink, markPalette }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
      <div style={{
        width: 28, height: 28, borderRadius: '50%',
        background: `radial-gradient(circle at 36% 32%, ${markPalette.core}, ${markPalette.mid} 55%, ${markPalette.edge})`,
        boxShadow: `0 2px 8px ${markPalette.glow}`,
      }} />
      <span style={{ fontSize: 23, fontWeight: 800, letterSpacing: -0.5, color: ink, whiteSpace: 'nowrap' }}>잘보이네</span>
    </div>
  );
}

// 큰 시작 버튼 + "여기를 눌러보세요" 힌트(탭 링 애니메이션)
function StartButton({ theme }) {
  return (
    <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      {/* 힌트 */}
      <div style={{
        fontSize: 19, fontWeight: 600, color: theme.hint, marginBottom: 14, whiteSpace: 'nowrap',
        display: 'flex', alignItems: 'center', gap: 7,
      }}>
        <span style={{ fontSize: 18 }}>👇</span> 여기를 눌러보세요
      </div>
      <div style={{ position: 'relative', width: '100%' }}>
        {/* 펄스 링 */}
        <div className="jbn-ring" style={{
          position: 'absolute', inset: 0, borderRadius: 26,
          border: `3px solid ${theme.btnBg}`, animation: 'jbn-ring 2.4s ease-out infinite', zIndex: 0,
        }} />
        <button style={{
          position: 'relative', zIndex: 1, width: '100%', height: 84, border: 'none', borderRadius: 26,
          background: theme.btnBg, color: theme.btnInk, fontFamily: JBN_FONT,
          fontSize: 30, fontWeight: 800, letterSpacing: -0.5, cursor: 'pointer', whiteSpace: 'nowrap',
          boxShadow: theme.btnShadow, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12,
        }}>
          시작하기
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke={theme.btnInk} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
            <path d="M5 12h13M13 6l6 6-6 6" />
          </svg>
        </button>
      </div>
    </div>
  );
}

// 가족·도우미 보조 링크
function HelperLink({ theme }) {
  return (
    <button style={{
      background: 'none', border: 'none', cursor: 'pointer', fontFamily: JBN_FONT,
      marginTop: 18, padding: '6px 4px', width: '100%',
      fontSize: 15.5, fontWeight: 500, lineHeight: 1.5, color: theme.helper, textAlign: 'center',
      textDecorationLine: 'underline', textUnderlineOffset: 4, textDecorationThickness: 1,
      textDecorationColor: theme.helperLine,
    }}>
      가족 및 어르신을 도와주시는 분은<br />여기를 눌러주세요
    </button>
  );
}

function Headline({ ink, sub }) {
  return (
    <div style={{ textAlign: 'center' }}>
      {sub && <div style={{ fontSize: 18, fontWeight: 600, color: sub.color, marginBottom: 12 }}>{sub.text}</div>}
      <h1 style={{
        margin: 0, fontSize: 43, fontWeight: 800, lineHeight: 1.24, letterSpacing: -1.1, color: ink,
        textWrap: 'balance',
      }}>
        어르신을 위한<br />쉬운 스마트폰
      </h1>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// A · 햇살 — 밝고 따뜻한 그라데이션, 떠오르는 햇살
// ════════════════════════════════════════════════════════════
function SplashA() {
  const theme = {
    bg: 'linear-gradient(180deg, #FFF3E0 0%, #FFE3C2 46%, #FBC79A 100%)',
    ink: '#5A2410',
    hint: '#C24A1E',
    btnBg: 'linear-gradient(180deg, #F2742E 0%, #E8541F 100%)',
    btnInk: '#FFFFFF',
    btnShadow: '0 12px 26px rgba(226,80,28,0.42), inset 0 1px 0 rgba(255,255,255,0.35)',
    helper: '#925236',
    helperLine: 'rgba(146,82,54,0.5)',
    deco: (
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', zIndex: 1, pointerEvents: 'none' }}>
        <div style={{ position: 'absolute', top: -70, right: -60, width: 230, height: 230, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(255,210,140,0.7), rgba(255,210,140,0) 70%)' }} />
        <div style={{ position: 'absolute', bottom: 120, left: -80, width: 240, height: 240, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(255,170,120,0.45), rgba(255,170,120,0) 70%)' }} />
      </div>
    ),
  };
  return (
    <Screen theme={theme}>
      <Wordmark ink="#A8431C" markPalette={{ core: '#FFE6A6', mid: '#F2A93B', edge: '#E8623A', glow: 'rgba(232,98,58,0.5)' }} />
      <div style={{ marginTop: 30 }}>
        <Headline ink={theme.ink} />
      </div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Mascot size={196} palette={{ core: '#FFF3CC', mid: '#FFCB66', edge: '#FBA24A', glow: 'rgba(255,180,90,0.55)' }} />
      </div>
      <StartButton theme={theme} />
      <HelperLink theme={theme} />
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// B · 노을 — 깊은 테라코타→마룬, 황금빛 햇살. 차분·고급
// ════════════════════════════════════════════════════════════
function SplashB() {
  const theme = {
    bg: 'linear-gradient(180deg, #B23A24 0%, #8E2A1E 50%, #5E1B16 100%)',
    ink: '#FFF1E0',
    hint: '#FFD79A',
    btnBg: 'linear-gradient(180deg, #FFD27A 0%, #F2A93B 100%)',
    btnInk: '#5A1E0C',
    btnShadow: '0 12px 28px rgba(0,0,0,0.32), inset 0 1px 0 rgba(255,255,255,0.5)',
    helper: 'rgba(255,225,200,0.82)',
    helperLine: 'rgba(255,210,170,0.45)',
    deco: (
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', zIndex: 1, pointerEvents: 'none' }}>
        <div style={{ position: 'absolute', top: '34%', left: '50%', transform: 'translate(-50%,-50%)', width: 360, height: 360, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(255,170,90,0.4), rgba(255,170,90,0) 66%)' }} />
        <div style={{ position: 'absolute', bottom: -90, right: -70, width: 250, height: 250, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(120,20,16,0.55), rgba(120,20,16,0) 70%)' }} />
      </div>
    ),
  };
  return (
    <Screen theme={theme}>
      <Wordmark ink="#FFE2BC" markPalette={{ core: '#FFEFC4', mid: '#FFC766', edge: '#F2872E', glow: 'rgba(255,170,80,0.6)' }} />
      <div style={{ marginTop: 30 }}>
        <Headline ink={theme.ink} />
      </div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Mascot size={200} palette={{ core: '#FFF1C8', mid: '#FFCB6B', edge: '#FBA945', glow: 'rgba(255,190,100,0.7)' }} />
      </div>
      <StartButton theme={theme} />
      <HelperLink theme={theme} />
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// C · 단정 — 깨끗한 아이보리, 최고 대비. 가독성 최우선 + 절제된 고급
// ════════════════════════════════════════════════════════════
function SplashC() {
  const theme = {
    bg: '#FDF7EE',
    ink: '#2E1606',
    hint: '#C0421B',
    btnBg: '#E0481C',
    btnInk: '#FFFFFF',
    btnShadow: '0 10px 24px rgba(224,72,28,0.34)',
    helper: '#6B4A36',
    helperLine: 'rgba(107,74,54,0.45)',
    deco: (
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', zIndex: 1, pointerEvents: 'none' }}>
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 10,
          background: 'linear-gradient(90deg, #E8623A, #F2A93B 50%, #F2C14E)' }} />
        <div style={{ position: 'absolute', top: '40%', right: -110, width: 260, height: 260, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(242,169,59,0.16), rgba(242,169,59,0) 70%)' }} />
      </div>
    ),
  };
  return (
    <Screen theme={theme}>
      <Wordmark ink="#C0421B" markPalette={{ core: '#FFE6A6', mid: '#F2A93B', edge: '#E8623A', glow: 'rgba(232,98,58,0.45)' }} />
      <div style={{ marginTop: 34 }}>
        <Headline ink={theme.ink} sub={{ text: '천천히, 쉽게 시작하세요', color: '#B06A3C' }} />
      </div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Mascot size={186} palette={{ core: '#FFF1C4', mid: '#FFC868', edge: '#FBA64A', glow: 'rgba(255,180,90,0.5)' }} />
      </div>
      <StartButton theme={theme} />
      <HelperLink theme={theme} />
    </Screen>
  );
}

Object.assign(window, { Mascot, SplashA, SplashB, SplashC });
