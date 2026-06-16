// shared.jsx — 공통 아이콘, 앱 카탈로그, 헬퍼

// 앱 카탈로그: 실제 한국 앱 색상/스타일을 추상화한 아이콘
// 아이콘은 SVG로 그려서 특정 회사 로고를 직접 베끼지 않도록 함 (간단한 글리프 + 브랜드 컬러)
const APP_CATALOG = [
  {
    id: 'phone', name: '전화', q: '전화를 자주 하시나요?',
    color: '#1B8A3A', glyph: '📞',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#1B8A3A"/>
        <path d="M22 18c0-1.5 1-2.5 2.5-2.5h6c1.5 0 2.5 1 3 2.5l2 6c.5 1.5 0 2.5-1 3.5l-3 2.5c2 5 6 9 11 11l2.5-3c1-1 2-1.5 3.5-1l6 2c1.5.5 2.5 1.5 2.5 3v6c0 1.5-1 2.5-2.5 2.5C32.5 50.5 13.5 31.5 22 18z" fill="#fff"/>
      </svg>
    )
  },
  {
    id: 'sms', name: '문자', q: '문자를 자주 하시나요?',
    color: '#0B5FD9',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#0B5FD9"/>
        <path d="M14 20c0-2 1.5-3.5 3.5-3.5h29c2 0 3.5 1.5 3.5 3.5v18c0 2-1.5 3.5-3.5 3.5h-15l-9 7v-7h-5c-2 0-3.5-1.5-3.5-3.5V20z" fill="#fff"/>
        <circle cx="24" cy="29" r="2.5" fill="#0B5FD9"/>
        <circle cx="32" cy="29" r="2.5" fill="#0B5FD9"/>
        <circle cx="40" cy="29" r="2.5" fill="#0B5FD9"/>
      </svg>
    )
  },
  {
    id: 'kakao', name: '카카오톡', q: '카카오톡을 하시나요?',
    color: '#FAE100',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#FAE100"/>
        <path d="M32 14c-11 0-19 7-19 15.5 0 5.5 3.5 10.5 9 13l-2.5 8 9-5.5c1 .2 2.3.3 3.5.3 11 0 19-7 19-15.8C51 21 43 14 32 14z" fill="#3B1E1E"/>
      </svg>
    )
  },
  {
    id: 'video', name: '동영상', q: '동영상 시청을 자주 하시나요?',
    color: '#E63946',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#E63946"/>
        <rect x="10" y="20" width="44" height="24" rx="6" fill="#fff"/>
        <path d="M27 27v10l10-5z" fill="#E63946"/>
      </svg>
    )
  },
  {
    id: 'camera', name: '카메라', q: '카메라를 자주 쓰시나요?',
    color: '#4A4A4A',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#2A2A2A"/>
        <rect x="10" y="20" width="44" height="28" rx="5" fill="#fff"/>
        <rect x="22" y="15" width="14" height="8" rx="2" fill="#fff"/>
        <circle cx="32" cy="34" r="9" fill="#2A2A2A"/>
        <circle cx="32" cy="34" r="6" fill="#666"/>
        <circle cx="46" cy="26" r="2" fill="#E63946"/>
      </svg>
    )
  },
  {
    id: 'weather', name: '날씨', q: '날씨를 자주 확인하시나요?',
    color: '#2BB3F0',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#2BB3F0"/>
        <circle cx="24" cy="26" r="9" fill="#FFD43A"/>
        <path d="M24 42c-6 0-10 4-10 8 0 3 2 5 5 5h22c4 0 7-3 7-7 0-5-4-8-9-8-1 0-2 .2-3 .5-1.5-3-5-5-9-5-1.5 0-3 .3-4 1z" fill="#fff"/>
      </svg>
    )
  },
  {
    id: 'taxi', name: '택시', q: '택시를 자주 부르시나요?',
    color: '#111111',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#FFC700"/>
        <path d="M14 36c0-1 .5-2 1.3-2.6L20 30l3-9c.5-1.5 2-2.5 3.5-2.5h11c1.5 0 3 1 3.5 2.5l3 9 4.7 3.4c.8.6 1.3 1.6 1.3 2.6v8c0 1-.8 2-2 2h-3c-1 0-2-.8-2-2v-2H21v2c0 1.2-.8 2-2 2h-3c-1 0-2-.8-2-2v-8z" fill="#111"/>
        <rect x="22" y="22" width="20" height="6" rx="1" fill="#FFC700"/>
        <circle cx="22" cy="42" r="3" fill="#FFC700"/>
        <circle cx="42" cy="42" r="3" fill="#FFC700"/>
      </svg>
    )
  },
  {
    id: 'bank', name: '은행', q: '은행 앱을 쓰시나요?',
    color: '#0F4C81',
    icon: (s = 1) => (
      <svg viewBox="0 0 64 64" width={64*s} height={64*s}>
        <rect x="0" y="0" width="64" height="64" rx="14" fill="#0F4C81"/>
        <path d="M32 12L12 22v4h40v-4L32 12z" fill="#fff"/>
        <rect x="14" y="28" width="4" height="18" fill="#fff"/>
        <rect x="22" y="28" width="4" height="18" fill="#fff"/>
        <rect x="30" y="28" width="4" height="18" fill="#fff"/>
        <rect x="38" y="28" width="4" height="18" fill="#fff"/>
        <rect x="46" y="28" width="4" height="18" fill="#fff"/>
        <rect x="12" y="48" width="40" height="4" fill="#fff"/>
      </svg>
    )
  },
];

// 음성 표시 배지 (스피커 아이콘 + 안내 중 점)
function VoiceBadge({ label = '음성 안내 중' }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 8,
      padding: '8px 14px', borderRadius: 999,
      background: '#0B5FD9', color: '#fff',
      fontSize: 16, fontWeight: 700,
    }}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
        <path d="M3 10v4a1 1 0 001 1h3l4 3.5V5.5L7 9H4a1 1 0 00-1 1z" fill="#fff"/>
        <path d="M16 8c1.5 1 2.5 2.5 2.5 4s-1 3-2.5 4" stroke="#fff" strokeWidth="2" strokeLinecap="round" fill="none"/>
        <path d="M19 5c2.5 1.5 4 4 4 7s-1.5 5.5-4 7" stroke="#fff" strokeWidth="2" strokeLinecap="round" fill="none" opacity=".7"/>
      </svg>
      <span>{label}</span>
      <span style={{
        width: 8, height: 8, borderRadius: '50%', background: '#fff',
        animation: 'pulse 1.2s infinite',
      }}/>
    </div>
  );
}

// 안드로이드 상태 바 (단순)
function StatusBar({ dark = false, time = '오전 9:30' }) {
  const c = dark ? '#fff' : '#1A1A1A';
  return (
    <div style={{
      height: 32, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 18px',
      fontSize: 14, fontWeight: 700, color: c, flexShrink: 0,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="16" height="12" viewBox="0 0 16 12"><path d="M8 11L0 4a11 11 0 0116 0L8 11z" fill={c}/></svg>
        <svg width="14" height="12" viewBox="0 0 14 12"><rect x="1" y="2" width="11" height="8" rx="1" fill="none" stroke={c} strokeWidth="1.4"/><rect x="2.5" y="3.5" width="7" height="5" fill={c}/><rect x="12.5" y="4.5" width="1" height="3" fill={c}/></svg>
      </div>
    </div>
  );
}

// 제스처 바
function GestureBar({ dark = false }) {
  return (
    <div style={{
      height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      <div style={{
        width: 120, height: 5, borderRadius: 3,
        background: dark ? '#fff' : '#1A1A1A', opacity: .5,
      }}/>
    </div>
  );
}

// 헤더 (뒤로가기 + 진행 표시 + 홈)
function ScreenHeader({ onBack, onHome, progress, total, title }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '14px 16px', borderBottom: '2px solid #E0DDD3',
      flexShrink: 0, background: '#fff',
    }}>
      {onBack && (
        <button onClick={onBack} style={{
          width: 60, height: 60, borderRadius: 16, border: '2px solid #1A1A1A',
          background: '#fff', fontSize: 18, fontWeight: 700, cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4,
        }}>
          <svg width="24" height="24" viewBox="0 0 24 24"><path d="M15 4l-8 8 8 8" fill="none" stroke="#1A1A1A" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
      )}
      <div style={{ flex: 1, textAlign: 'center' }}>
        {progress != null && total != null ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6, alignItems: 'center' }}>
            <div style={{ fontSize: 18, fontWeight: 700, color: '#4A4A4A' }}>
              {progress} / {total}
            </div>
            <div style={{
              width: 200, height: 8, borderRadius: 4, background: '#E0DDD3',
              overflow: 'hidden',
            }}>
              <div style={{
                width: `${(progress/total)*100}%`, height: '100%',
                background: '#0B5FD9', transition: 'width .3s',
              }}/>
            </div>
          </div>
        ) : title ? (
          <div style={{ fontSize: 24, fontWeight: 800, color: '#1A1A1A' }}>{title}</div>
        ) : null}
      </div>
      {onHome ? (
        <button onClick={onHome} style={{
          width: 60, height: 60, borderRadius: 16, border: '2px solid #1A1A1A',
          background: '#fff', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="28" height="28" viewBox="0 0 24 24"><path d="M3 11l9-8 9 8v9a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2v-9z" fill="#1A1A1A"/></svg>
        </button>
      ) : <div style={{ width: 60 }}/>}
    </div>
  );
}

Object.assign(window, { APP_CATALOG, VoiceBadge, StatusBar, GestureBar, ScreenHeader });
