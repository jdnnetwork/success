// home.jsx — 메인 홈 화면 (2/3/4/6 그리드)

function HomeScreen({ state, setState, navigate }) {
  const selectedIds = Object.keys(state.selectedApps || {});
  // Tweak override or actual count
  const override = state.gridOverride;
  const count = override || selectedIds.length || 4;
  // 만약 override 가 사용자 선택보다 크면, 카탈로그에서 채워서 보여줌
  let apps;
  if (override) {
    // override 시: 선택된 앱 우선 + 부족하면 카탈로그에서 추가
    const picked = APP_CATALOG.filter(a => state.selectedApps?.[a.id]);
    if (picked.length >= override) apps = picked.slice(0, override);
    else {
      const rest = APP_CATALOG.filter(a => !state.selectedApps?.[a.id]);
      apps = [...picked, ...rest].slice(0, override);
    }
  } else {
    apps = selectedIds.length
      ? APP_CATALOG.filter(a => state.selectedApps[a.id])
      : APP_CATALOG.slice(0, 4);
  }

  // 그리드 레이아웃 결정
  const layout = (() => {
    if (count <= 2) return { cols: 1, rows: 2 };
    if (count === 3) return { cols: 1, rows: 3 };
    if (count === 4) return { cols: 2, rows: 2 };
    if (count <= 6) return { cols: 2, rows: 3 };
    return { cols: 2, rows: 4 };
  })();

  const now = new Date();
  const time = `${now.getHours() < 12 ? '오전' : '오후'} ${((now.getHours()+11)%12)+1}:${String(now.getMinutes()).padStart(2, '0')}`;

  // Long press for 보호자 모드 (5sec)
  const longPressRef = React.useRef(null);
  const startLongPress = () => {
    longPressRef.current = setTimeout(() => {
      navigate('guardianGate');
    }, 1500);
  };
  const cancelLongPress = () => {
    if (longPressRef.current) clearTimeout(longPressRef.current);
  };

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', height: '100%',
      background: '#FAF7F0',
    }}>
      {/* 인사 + 시간 */}
      <div style={{
        padding: '16px 20px 12px', display: 'flex', alignItems: 'center',
        justifyContent: 'space-between', flexShrink: 0,
      }}
        onMouseDown={startLongPress} onMouseUp={cancelLongPress} onMouseLeave={cancelLongPress}
        onTouchStart={startLongPress} onTouchEnd={cancelLongPress}
      >
        <div>
          <div style={{ fontSize: 18, fontWeight: 700, color: '#4A4A4A' }}>
            5월 4일 월요일
          </div>
          <div style={{ fontSize: 36, fontWeight: 900, color: '#1A1A1A', letterSpacing: '-0.02em' }}>
            {time}
          </div>
        </div>
        <div style={{
          padding: '8px 14px', borderRadius: 999, background: '#1B8A3A',
          color: '#fff', fontSize: 16, fontWeight: 700, display: 'flex',
          alignItems: 'center', gap: 6,
        }}>
          <span style={{ fontSize: 18 }}>☀</span> 맑음 · 22°
        </div>
      </div>

      {/* 인사말 */}
      <div style={{
        padding: '0 20px 12px', flexShrink: 0,
      }}>
        <div style={{ fontSize: 28, fontWeight: 800, color: '#1A1A1A', letterSpacing: '-0.02em' }}>
          {state.userName || '어르신'}, 안녕하세요
        </div>
      </div>

      {/* 앱 그리드 — 화면 가득 */}
      <div style={{
        flex: 1, padding: '8px 16px 12px',
        display: 'grid',
        gridTemplateColumns: `repeat(${layout.cols}, 1fr)`,
        gridTemplateRows: `repeat(${layout.rows}, 1fr)`,
        gap: 12, minHeight: 0,
      }}>
        {apps.map(app => (
          <button key={app.id}
            onClick={() => navigate('appOpened', { app })}
            style={{
              borderRadius: 22, border: '3px solid #1A1A1A',
              background: '#fff', cursor: 'pointer',
              display: 'flex',
              flexDirection: layout.cols === 1 && count === 3 ? 'row' : 'column',
              alignItems: 'center', justifyContent: 'center',
              gap: layout.cols === 1 && count === 3 ? 16 : 10,
              padding: layout.cols === 1 && count === 3 ? '8px 16px' : 10,
              minHeight: 0, overflow: 'hidden',
              boxShadow: '0 6px 0 #1A1A1A',
              transition: 'transform .1s',
            }}
            onMouseDown={e => e.currentTarget.style.transform = 'translateY(3px)'}
            onMouseUp={e => e.currentTarget.style.transform = ''}
            onMouseLeave={e => e.currentTarget.style.transform = ''}
          >
            <div style={{
              width: layout.cols === 1 ? (count === 3 ? 64 : 96) : 76,
              height: layout.cols === 1 ? (count === 3 ? 64 : 96) : 76,
              borderRadius: 18, background: app.color,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 4px 12px rgba(0,0,0,0.12)',
              overflow: 'hidden', flexShrink: 0,
            }}>
              <div style={{ transform: layout.cols === 1 && count === 3 ? 'scale(0.7)' : (layout.cols === 1 ? 'scale(1.05)' : 'scale(0.9)') }}>
                {app.icon(1)}
              </div>
            </div>
            <div style={{
              fontSize: layout.cols === 1 ? (count === 3 ? 30 : 36) : (count <= 4 ? 28 : 22),
              fontWeight: 900, color: '#1A1A1A',
              letterSpacing: '-0.02em',
            }}>
              {app.name}
            </div>
          </button>
        ))}
      </div>

      {/* 긴급 전화 — 항상 하단 고정, 빨간색 */}
      <div style={{ padding: '0 16px 14px', flexShrink: 0 }}>
        <button onClick={() => navigate('emergency')}
          className="bigbtn bigbtn--danger"
          style={{ minHeight: 88, fontSize: 30 }}>
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
            <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.13.96.37 1.9.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.91.33 1.85.57 2.81.7A2 2 0 0122 16.92z" fill="#fff"/>
          </svg>
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 10,
            padding: '4px 10px', background: '#fff', color: '#C8102E',
            borderRadius: 12, fontSize: 22, fontWeight: 900,
          }}>SOS</span>
          긴급 전화
        </button>
      </div>
    </div>
  );
}

// 앱 열림 시 — 진짜 앱이 아니라 더미. "앱이 열립니다" 안내
function AppOpenedScreen({ app, onBack }) {
  return (
    <div style={{
      height: '100%', background: app.color,
      display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', gap: 24,
      color: '#fff', padding: 24,
    }}>
      <div style={{ transform: 'scale(2.2)' }}>{app.icon(1)}</div>
      <div style={{ fontSize: 40, fontWeight: 900, letterSpacing: '-0.02em' }}>
        {app.name}
      </div>
      <div style={{ fontSize: 22, fontWeight: 600, opacity: .9, textAlign: 'center' }}>
        실제 앱이 열립니다<br/>(프로토타입 화면)
      </div>
      <button onClick={onBack} style={{
        marginTop: 24, padding: '20px 40px', borderRadius: 20,
        background: '#fff', color: '#1A1A1A', fontSize: 28, fontWeight: 800,
        border: 'none', cursor: 'pointer', minHeight: 80,
        boxShadow: '0 6px 0 rgba(0,0,0,0.4)',
      }}>← 홈으로 돌아가기</button>
    </div>
  );
}

Object.assign(window, { HomeScreen, AppOpenedScreen });
