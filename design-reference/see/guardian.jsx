// guardian.jsx — 보호자 진입, 보호자 관리, 로그인

function GuardianGate({ navigate }) {
  const [pin, setPin] = React.useState('');
  const correct = '1234';
  const [shake, setShake] = React.useState(false);

  const press = (n) => {
    if (pin.length >= 4) return;
    const next = pin + n;
    setPin(next);
    if (next.length === 4) {
      setTimeout(() => {
        if (next === correct) navigate('guardianHome');
        else { setShake(true); setTimeout(() => { setShake(false); setPin(''); }, 500); }
      }, 200);
    }
  };
  const back = () => setPin(pin.slice(0, -1));

  return (
    <div style={{
      height: '100%', background: '#1A1A1A', color: '#fff',
      display: 'flex', flexDirection: 'column', padding: 20,
    }}>
      <div style={{ display: 'flex', justifyContent: 'flex-start' }}>
        <button onClick={() => navigate('home')} style={{
          width: 56, height: 56, borderRadius: 14, border: '2px solid #fff',
          background: 'transparent', color: '#fff', cursor: 'pointer',
          fontSize: 24,
        }}>✕</button>
      </div>

      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 28,
      }}>
        <div style={{ fontSize: 56 }}>🔒</div>
        <div style={{ fontSize: 28, fontWeight: 800, textAlign: 'center', letterSpacing: '-0.02em' }}>
          보호자 모드
        </div>
        <div style={{ fontSize: 18, opacity: .7, textAlign: 'center', marginTop: -16 }}>
          비밀번호 4자리를 입력하세요
        </div>

        <div style={{
          display: 'flex', gap: 14, transition: 'transform .1s',
          transform: shake ? 'translateX(8px)' : '',
        }} className={shake ? 'pulse' : ''}>
          {[0,1,2,3].map(i => (
            <div key={i} style={{
              width: 24, height: 24, borderRadius: '50%',
              background: i < pin.length ? (shake ? '#C8102E' : '#fff') : 'transparent',
              border: '2px solid #fff',
              transition: 'background .15s',
            }}/>
          ))}
        </div>
        <div style={{ fontSize: 14, opacity: .5, marginTop: -16 }}>힌트: 1234</div>
      </div>

      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)',
        gap: 10, paddingBottom: 8,
      }}>
        {[1,2,3,4,5,6,7,8,9].map(n => (
          <button key={n} onClick={() => press(String(n))} style={{
            height: 70, borderRadius: 18,
            background: 'rgba(255,255,255,0.1)', color: '#fff',
            border: '1px solid rgba(255,255,255,0.2)', cursor: 'pointer',
            fontSize: 32, fontWeight: 700,
          }}>{n}</button>
        ))}
        <div/>
        <button onClick={() => press('0')} style={{
          height: 70, borderRadius: 18,
          background: 'rgba(255,255,255,0.1)', color: '#fff',
          border: '1px solid rgba(255,255,255,0.2)', cursor: 'pointer',
          fontSize: 32, fontWeight: 700,
        }}>0</button>
        <button onClick={back} style={{
          height: 70, borderRadius: 18,
          background: 'transparent', color: '#fff',
          border: '1px solid rgba(255,255,255,0.2)', cursor: 'pointer',
          fontSize: 24,
        }}>⌫</button>
      </div>
    </div>
  );
}

function GuardianHome({ state, setState, navigate }) {
  const [tab, setTab] = React.useState('home');
  const tabs = [
    { id: 'home', label: '홈 화면', icon: '📱' },
    { id: 'med', label: '약 관리', icon: '💊' },
    { id: 'sos', label: '긴급 연락', icon: '🚨' },
    { id: 'usage', label: '사용 현황', icon: '📊' },
  ];

  return (
    <div style={{
      height: '100%', background: '#F0F4F8',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* 보호자 헤더 (다른 톤 — 어두운 네이비) */}
      <div style={{
        background: '#0F2847', color: '#fff',
        padding: '16px 20px 14px', flexShrink: 0,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, opacity: .7, letterSpacing: '0.1em' }}>
              보호자 모드
            </div>
            <div style={{ fontSize: 24, fontWeight: 900, letterSpacing: '-0.02em' }}>
              {state.userName || '어머니'} 관리
            </div>
          </div>
          <button onClick={() => navigate('home')} style={{
            padding: '10px 14px', borderRadius: 12,
            background: 'rgba(255,255,255,0.15)', color: '#fff',
            border: '1px solid rgba(255,255,255,0.3)', cursor: 'pointer',
            fontSize: 14, fontWeight: 700,
          }}>나가기</button>
        </div>
      </div>

      <div style={{
        display: 'flex', gap: 6, padding: '10px 12px',
        overflowX: 'auto', flexShrink: 0, background: '#fff',
        borderBottom: '1px solid #E0DDD3',
      }} className="no-scrollbar">
        {tabs.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            padding: '10px 14px', borderRadius: 999,
            background: tab === t.id ? '#0F2847' : '#F0F4F8',
            color: tab === t.id ? '#fff' : '#1A1A1A',
            border: 'none', cursor: 'pointer', flexShrink: 0,
            fontSize: 14, fontWeight: 700, display: 'flex', gap: 6, alignItems: 'center',
          }}>
            <span>{t.icon}</span>{t.label}
          </button>
        ))}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: 16 }} className="fade-up" key={tab}>
        {tab === 'home' && <GuardianHomeTab state={state} setState={setState}/>}
        {tab === 'med' && <GuardianMedTab state={state} setState={setState}/>}
        {tab === 'sos' && <GuardianSosTab state={state} setState={setState}/>}
        {tab === 'usage' && <GuardianUsageTab/>}
      </div>
    </div>
  );
}

function GuardianHomeTab({ state, setState }) {
  const selectedIds = state.selectedApps || {};
  const toggle = (id) => {
    const s = { ...selectedIds };
    if (s[id]) delete s[id]; else s[id] = true;
    setState({ ...state, selectedApps: s });
  };
  const count = Object.keys(selectedIds).length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{
        background: '#fff', borderRadius: 14, padding: 14,
        border: '1px solid #E0DDD3',
      }}>
        <div style={{ fontSize: 13, color: '#4A4A4A', fontWeight: 700, marginBottom: 4 }}>
          현재 홈에 표시된 앱
        </div>
        <div style={{ fontSize: 22, fontWeight: 900 }}>
          {count}개 <span style={{ fontSize: 13, color: '#4A4A4A' }}>
            ({count <= 2 ? '큰 카드 2개' : count === 3 ? '큰 카드 3개' : count === 4 ? '2x2 그리드' : '2x3 그리드'})
          </span>
        </div>
      </div>

      <div style={{ fontSize: 14, fontWeight: 700, color: '#4A4A4A', marginTop: 4 }}>
        홈에 표시할 앱 선택
      </div>

      {APP_CATALOG.map(app => {
        const on = !!selectedIds[app.id];
        return (
          <div key={app.id} onClick={() => toggle(app.id)} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: 12, borderRadius: 14,
            background: '#fff',
            border: on ? '2px solid #0B5FD9' : '1px solid #E0DDD3',
            cursor: 'pointer',
          }}>
            <div style={{ width: 48, height: 48 }}>
              <div style={{ transform: 'scale(0.75)', transformOrigin: '0 0' }}>{app.icon(1)}</div>
            </div>
            <div style={{ flex: 1, fontSize: 16, fontWeight: 700 }}>{app.name}</div>
            <div style={{
              width: 44, height: 26, borderRadius: 999,
              background: on ? '#0B5FD9' : '#D0D0D0',
              position: 'relative', transition: 'background .15s',
            }}>
              <div style={{
                position: 'absolute', top: 2, left: on ? 20 : 2,
                width: 22, height: 22, borderRadius: '50%', background: '#fff',
                transition: 'left .15s', boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
              }}/>
            </div>
          </div>
        );
      })}
    </div>
  );
}

function GuardianMedTab({ state, setState }) {
  const med = state.medications;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      {!med ? (
        <div style={{
          padding: 24, background: '#fff', borderRadius: 14,
          border: '1px solid #E0DDD3', textAlign: 'center',
        }}>
          <div style={{ fontSize: 36 }}>💊</div>
          <div style={{ fontSize: 16, fontWeight: 700, marginTop: 8 }}>등록된 약이 없어요</div>
          <button onClick={() => setState({ ...state, medications: { count: 2, schedule: { 아침: 8, 저녁: 19 } } })} style={{
            marginTop: 16, padding: '12px 20px', borderRadius: 12,
            background: '#0B5FD9', color: '#fff', border: 'none',
            fontSize: 14, fontWeight: 700, cursor: 'pointer',
          }}>약 추가하기</button>
        </div>
      ) : (
        <>
          <div style={{
            background: '#fff', borderRadius: 14, padding: 16,
            border: '1px solid #E0DDD3',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
              <div style={{
                width: 40, height: 40, borderRadius: 10,
                background: '#7C3AED', display: 'flex',
                alignItems: 'center', justifyContent: 'center', fontSize: 24,
              }}>💊</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 16, fontWeight: 800 }}>혈압약</div>
                <div style={{ fontSize: 13, color: '#4A4A4A' }}>하루 {med.count}번</div>
              </div>
              <button style={{
                padding: '6px 12px', borderRadius: 8, background: '#F0F4F8',
                border: 'none', fontSize: 13, fontWeight: 700, cursor: 'pointer',
              }}>수정</button>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {Object.entries(med.schedule || {}).map(([period, hour]) => (
                <div key={period} style={{
                  display: 'flex', justifyContent: 'space-between',
                  padding: '10px 12px', borderRadius: 10,
                  background: '#F0F4F8',
                }}>
                  <span style={{ fontSize: 14, fontWeight: 700 }}>{period}</span>
                  <span style={{ fontSize: 14, fontWeight: 700, color: '#7C3AED' }}>
                    {hour < 12 ? '오전' : '오후'} {hour <= 12 ? hour : hour - 12}:00
                  </span>
                </div>
              ))}
            </div>
          </div>
          <button style={{
            padding: 14, borderRadius: 12, background: '#fff',
            border: '2px dashed #0B5FD9', color: '#0B5FD9',
            fontSize: 14, fontWeight: 700, cursor: 'pointer',
          }}>+ 새 약 추가</button>
        </>
      )}
    </div>
  );
}

function GuardianSosTab({ state, setState }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{
        background: '#fff', borderRadius: 14, padding: 16,
        border: '1px solid #E0DDD3',
      }}>
        <div style={{ fontSize: 13, color: '#4A4A4A', fontWeight: 700, marginBottom: 6 }}>
          보호자 연락처 (긴급 시 표시됨)
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 10 }}>
          <div>
            <label style={{ fontSize: 12, color: '#4A4A4A', fontWeight: 700 }}>이름</label>
            <input value={state.guardianName || '딸 김지영'}
              onChange={e => setState({ ...state, guardianName: e.target.value })}
              style={{
                width: '100%', padding: '10px 12px', marginTop: 4,
                borderRadius: 10, border: '1px solid #E0DDD3', fontSize: 16,
              }}/>
          </div>
          <div>
            <label style={{ fontSize: 12, color: '#4A4A4A', fontWeight: 700 }}>전화번호</label>
            <input value={state.guardianPhone || '010-1234-5678'}
              onChange={e => setState({ ...state, guardianPhone: e.target.value })}
              style={{
                width: '100%', padding: '10px 12px', marginTop: 4,
                borderRadius: 10, border: '1px solid #E0DDD3', fontSize: 16,
              }}/>
          </div>
        </div>
      </div>

      <div style={{
        background: '#fff', borderRadius: 14, padding: 16,
        border: '1px solid #E0DDD3',
      }}>
        <div style={{ fontSize: 13, color: '#4A4A4A', fontWeight: 700, marginBottom: 6 }}>
          기본 긴급 번호 (변경 불가)
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 8 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0' }}>
            <span style={{ fontWeight: 700 }}>🚑 119 구급차</span>
            <span style={{ color: '#C8102E', fontWeight: 700 }}>119</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0', borderTop: '1px solid #F0F0F0' }}>
            <span style={{ fontWeight: 700 }}>👮 112 경찰</span>
            <span style={{ color: '#0B5FD9', fontWeight: 700 }}>112</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function GuardianUsageTab() {
  const days = [
    { d: '오늘', open: 12, sos: 0, med: '✓' },
    { d: '어제', open: 8, sos: 0, med: '✓' },
    { d: '이틀 전', open: 14, sos: 1, med: '✗' },
    { d: '3일 전', open: 6, sos: 0, med: '✓' },
  ];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{
        background: '#fff', borderRadius: 14, padding: 16,
        border: '1px solid #E0DDD3',
      }}>
        <div style={{ fontSize: 13, color: '#4A4A4A', fontWeight: 700 }}>지난 7일 활동 요약</div>
        <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
          <div style={{ flex: 1, padding: 10, background: '#F0F4F8', borderRadius: 10 }}>
            <div style={{ fontSize: 24, fontWeight: 900 }}>54</div>
            <div style={{ fontSize: 11, color: '#4A4A4A' }}>앱 열기</div>
          </div>
          <div style={{ flex: 1, padding: 10, background: '#FFF5F5', borderRadius: 10 }}>
            <div style={{ fontSize: 24, fontWeight: 900, color: '#C8102E' }}>1</div>
            <div style={{ fontSize: 11, color: '#4A4A4A' }}>긴급 호출</div>
          </div>
          <div style={{ flex: 1, padding: 10, background: '#F3EBFF', borderRadius: 10 }}>
            <div style={{ fontSize: 24, fontWeight: 900, color: '#7C3AED' }}>6/7</div>
            <div style={{ fontSize: 11, color: '#4A4A4A' }}>약 복용</div>
          </div>
        </div>
      </div>

      {days.map((d, i) => (
        <div key={i} style={{
          background: '#fff', padding: 14, borderRadius: 12,
          border: '1px solid #E0DDD3', display: 'flex',
          alignItems: 'center', gap: 12,
        }}>
          <div style={{ width: 60, fontSize: 14, fontWeight: 700 }}>{d.d}</div>
          <div style={{ flex: 1, fontSize: 13, color: '#4A4A4A' }}>
            앱 {d.open}회 · 긴급 {d.sos}회
          </div>
          <div style={{
            padding: '4px 10px', borderRadius: 999,
            background: d.med === '✓' ? '#E8F5EC' : '#FFE4E4',
            color: d.med === '✓' ? '#1B8A3A' : '#C8102E',
            fontSize: 12, fontWeight: 800,
          }}>
            약 {d.med}
          </div>
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { GuardianGate, GuardianHome });
