// alerts.jsx — 약 알림, 긴급 전화

function MedAlertScreen({ state, navigate }) {
  return (
    <div style={{
      height: '100%', background: '#7C3AED',
      display: 'flex', flexDirection: 'column',
      color: '#fff', padding: 24,
    }}>
      <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 12 }}>
        <VoiceBadge label="소리로 알려드리고 있어요"/>
      </div>

      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 32,
      }}>
        <div style={{ position: 'relative', width: 200, height: 200 }}>
          <div className="ring-wave" style={{ color: '#fff' }}/>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: '50%',
            background: '#fff', display: 'flex', alignItems: 'center',
            justifyContent: 'center', fontSize: 110,
          }} className="pulse">💊</div>
        </div>

        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 22, fontWeight: 700, opacity: .9, marginBottom: 8 }}>
            오전 8:00
          </div>
          <div style={{ fontSize: 48, fontWeight: 900, letterSpacing: '-0.03em', lineHeight: 1.2 }}>
            약 드실<br/>시간이에요
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingBottom: 8 }}>
        <button className="bigbtn"
          onClick={() => navigate('home')}
          style={{
            background: '#fff', color: '#7C3AED', fontSize: 32,
            boxShadow: '0 6px 0 rgba(0,0,0,0.3)',
          }}>
          <span style={{ fontSize: 40 }}>✓</span> 먹었어요
        </button>
        <button className="bigbtn"
          onClick={() => navigate('home')}
          style={{
            background: 'transparent', color: '#fff',
            border: '3px solid #fff', fontSize: 26,
            boxShadow: '0 6px 0 rgba(0,0,0,0.3)',
          }}>
          나중에 (10분 뒤 다시 알림)
        </button>
      </div>
    </div>
  );
}

function EmergencyScreen({ navigate, state }) {
  const [calling, setCalling] = React.useState(null);

  if (calling) {
    return (
      <div style={{
        height: '100%', background: '#1A1A1A', color: '#fff',
        display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 24, padding: 24,
      }}>
        <div style={{ position: 'relative', width: 180, height: 180 }}>
          <div className="ring-wave" style={{ color: calling.color }}/>
          <div className="ring-wave" style={{ color: calling.color, animationDelay: '.6s' }}/>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: '50%',
            background: calling.color, display: 'flex',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="80" height="80" viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.13.96.37 1.9.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.91.33 1.85.57 2.81.7A2 2 0 0122 16.92z" fill="#fff"/></svg>
          </div>
        </div>
        <div style={{ fontSize: 22, fontWeight: 700, opacity: .8 }}>전화 거는 중</div>
        <div style={{ fontSize: 56, fontWeight: 900, letterSpacing: '-0.02em' }}>
          {calling.name}
        </div>
        <div style={{ fontSize: 32, fontWeight: 700, opacity: .9 }}>
          {calling.number}
        </div>
        <button onClick={() => setCalling(null)} style={{
          marginTop: 24, width: 96, height: 96, borderRadius: '50%',
          background: '#C8102E', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="48" height="48" viewBox="0 0 24 24" style={{ transform: 'rotate(135deg)' }}><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.13.96.37 1.9.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.91.33 1.85.57 2.81.7A2 2 0 0122 16.92z" fill="#fff"/></svg>
        </button>
      </div>
    );
  }

  const contacts = [
    { name: '119 구급차', number: '119', color: '#C8102E', sub: '아플 때, 다쳤을 때', icon: '🚑' },
    { name: '112 경찰', number: '112', color: '#0B5FD9', sub: '도움이 필요할 때', icon: '👮' },
    { name: state.guardianName || '딸 김지영', number: state.guardianPhone || '010-1234-5678', color: '#1B8A3A', sub: '보호자에게 전화', icon: '👨‍👩‍👧' },
  ];

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', height: '100%',
      background: '#FFF5F5',
    }}>
      <ScreenHeader onBack={() => navigate('home')} title="긴급 전화"/>
      <div className="fade-up" style={{
        flex: 1, padding: '20px 16px 16px',
        display: 'flex', flexDirection: 'column', gap: 14,
      }}>
        <div style={{
          background: '#fff', border: '3px solid #C8102E', borderRadius: 18,
          padding: '14px 18px', textAlign: 'center',
          fontSize: 20, fontWeight: 700, color: '#C8102E',
        }}>
          버튼을 누르면 바로 전화가 걸려요
        </div>

        {contacts.map(c => (
          <button key={c.number}
            onClick={() => setCalling(c)}
            style={{
              flex: 1, minHeight: 130, borderRadius: 22,
              background: c.color, color: '#fff', cursor: 'pointer',
              border: 'none', padding: '16px 20px',
              display: 'flex', alignItems: 'center', gap: 18,
              boxShadow: `0 6px 0 rgba(0,0,0,0.3)`,
              textAlign: 'left',
            }}>
            <div style={{
              width: 80, height: 80, borderRadius: 20,
              background: 'rgba(255,255,255,0.2)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 44, flexShrink: 0,
            }}>{c.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 18, fontWeight: 700, opacity: .9 }}>{c.sub}</div>
              <div style={{ fontSize: 36, fontWeight: 900, letterSpacing: '-0.02em' }}>{c.name}</div>
              <div style={{ fontSize: 22, fontWeight: 700, opacity: .95, marginTop: 2 }}>{c.number}</div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { MedAlertScreen, EmergencyScreen });
