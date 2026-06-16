// onboarding.jsx — 앱 질문 + 약 설정 흐름

function OnboardingApps({ state, setState, onDone }) {
  const idx = state.onbAppIdx || 0;
  const apps = APP_CATALOG;
  const cur = apps[idx];

  const answer = (yes) => {
    const selected = { ...(state.selectedApps || {}) };
    if (yes) selected[cur.id] = true;
    else delete selected[cur.id];
    if (idx + 1 < apps.length) {
      setState({ ...state, onbAppIdx: idx + 1, selectedApps: selected });
    } else {
      setState({ ...state, onbAppIdx: 0, selectedApps: selected });
      onDone();
    }
  };

  const back = () => {
    if (idx > 0) setState({ ...state, onbAppIdx: idx - 1 });
  };

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', height: '100%',
      background: '#FAF7F0',
    }}>
      <ScreenHeader
        onBack={idx > 0 ? back : null}
        progress={idx + 1} total={apps.length}
      />
      <div className="fade-up" key={idx} style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        padding: '12px 20px 16px', gap: 14, minHeight: 0,
      }}>
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <VoiceBadge label="질문을 읽어드릴게요"/>
        </div>

        {/* 앱 아이콘 + 이름 */}
        <div style={{
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
          padding: '4px 0',
        }}>
          <div style={{
            width: 116, height: 116, borderRadius: 28,
            background: cur.color, display: 'flex',
            alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(0,0,0,0.15)',
            overflow: 'hidden',
          }}>
            <div style={{ transform: 'scale(1.15)' }}>{cur.icon(1)}</div>
          </div>
          <div style={{ fontSize: 30, fontWeight: 900, color: '#1A1A1A', letterSpacing: '-0.02em' }}>
            {cur.name}
          </div>
        </div>

        {/* 질문 */}
        <div style={{
          background: '#fff', borderRadius: 18, padding: '16px 16px',
          border: '3px solid #1A1A1A',
          fontSize: 24, fontWeight: 800, color: '#1A1A1A',
          textAlign: 'center', lineHeight: 1.35,
          letterSpacing: '-0.02em',
        }}>
          {cur.q}
        </div>

        <div style={{ flex: 1, minHeight: 8 }}/>

        {/* 답변 버튼 — 네/아니요 */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <button className="bigbtn bigbtn--primary" onClick={() => answer(true)} style={{ minHeight: 84, fontSize: 28 }}>
            <span style={{ fontSize: 32 }}>✓</span> 네, 자주 써요
          </button>
          <button className="bigbtn bigbtn--ghost" onClick={() => answer(false)} style={{ minHeight: 84, fontSize: 28 }}>
            아니요
          </button>
        </div>
      </div>
    </div>
  );
}

function OnboardingMed({ state, setState, onDone }) {
  const step = state.medStep || 'ask';

  if (step === 'ask') {
    return (
      <div style={{
        display: 'flex', flexDirection: 'column', height: '100%',
        background: '#FAF7F0',
      }}>
        <ScreenHeader title="약 복용 설정"/>
        <div className="fade-up" style={{
          flex: 1, padding: '12px 20px 16px', display: 'flex', flexDirection: 'column', gap: 14, minHeight: 0,
        }}>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <VoiceBadge label="질문을 읽어드릴게요"/>
          </div>

          <div style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center',
            gap: 8, padding: '4px 0',
          }}>
            <div style={{
              width: 116, height: 116, borderRadius: 28,
              background: '#7C3AED',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 70,
            }}>💊</div>
          </div>

          <div style={{
            background: '#fff', borderRadius: 18, padding: '18px 16px',
            border: '3px solid #1A1A1A',
            fontSize: 28, fontWeight: 800, textAlign: 'center', lineHeight: 1.35,
            letterSpacing: '-0.02em',
          }}>
            매일 약을<br/>드시나요?
          </div>

          <div style={{ flex: 1, minHeight: 8 }}/>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <button className="bigbtn bigbtn--primary"
              onClick={() => setState({ ...state, medStep: 'count' })}
              style={{ minHeight: 84, fontSize: 28 }}>
              <span style={{ fontSize: 32 }}>✓</span> 네, 챙겨주세요
            </button>
            <button className="bigbtn bigbtn--ghost"
              onClick={() => { setState({ ...state, medStep: 'ask', medications: null }); onDone(); }}
              style={{ minHeight: 84, fontSize: 28 }}>
              아니요
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (step === 'count') {
    return (
      <div style={{
        display: 'flex', flexDirection: 'column', height: '100%',
        background: '#FAF7F0',
      }}>
        <ScreenHeader
          onBack={() => setState({ ...state, medStep: 'ask' })}
          title="약 복용 설정"
        />
        <div className="fade-up" style={{
          flex: 1, padding: '14px 20px 16px', display: 'flex', flexDirection: 'column', gap: 14, minHeight: 0,
        }}>
          <div style={{
            background: '#fff', borderRadius: 18, padding: '18px 16px',
            border: '3px solid #1A1A1A',
            fontSize: 26, fontWeight: 800, textAlign: 'center', lineHeight: 1.35,
            letterSpacing: '-0.02em',
          }}>
            하루에 몇 번<br/>드세요?
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1, 2, 3].map(n => (
              <button key={n}
                className="bigbtn bigbtn--ghost"
                onClick={() => {
                  const times = n === 1 ? ['아침'] :
                                n === 2 ? ['아침', '저녁'] :
                                          ['아침', '점심', '저녁'];
                  setState({
                    ...state, medStep: 'time',
                    medCount: n, medTimes: times, medTimeIdx: 0,
                    medications: { count: n, schedule: {} }
                  });
                }}
                style={{ minHeight: 88, fontSize: 24, gap: 14 }}>
                <span style={{ fontSize: 44, fontWeight: 900, color: '#7C3AED' }}>{n}</span>
                <span>번</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (step === 'time') {
    const labels = state.medTimes || ['아침'];
    const i = state.medTimeIdx || 0;
    const period = labels[i];
    const hours = period === '아침' ? [6, 7, 8, 9, 10] :
                  period === '점심' ? [11, 12, 13, 14] :
                                       [17, 18, 19, 20, 21];
    return (
      <div style={{
        display: 'flex', flexDirection: 'column', height: '100%',
        background: '#FAF7F0',
      }}>
        <ScreenHeader
          onBack={() => {
            if (i > 0) setState({ ...state, medTimeIdx: i - 1 });
            else setState({ ...state, medStep: 'count' });
          }}
          progress={i + 1} total={labels.length}
        />
        <div className="fade-up" key={i} style={{
          flex: 1, padding: '14px 20px 16px', display: 'flex', flexDirection: 'column', gap: 14, minHeight: 0,
        }}>
          <div style={{
            background: '#fff', borderRadius: 18, padding: '16px 14px',
            border: '3px solid #1A1A1A',
            fontSize: 24, fontWeight: 800, textAlign: 'center', lineHeight: 1.35,
            letterSpacing: '-0.02em',
          }}>
            <span style={{ color: '#7C3AED' }}>{period}</span>에<br/>
            몇 시에 드세요?
          </div>

          <div style={{
            display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)',
            gap: 10, alignContent: 'start',
          }}>
            {hours.map(h => {
              const display = h <= 12 ? h : h - 12;
              const ampm = h < 12 ? '오전' : '오후';
              return (
                <button key={h}
                  onClick={() => {
                    const sched = { ...(state.medications?.schedule || {}) };
                    sched[period] = h;
                    const next = { ...state, medications: { ...state.medications, schedule: sched } };
                    if (i + 1 < labels.length) {
                      setState({ ...next, medTimeIdx: i + 1 });
                    } else {
                      setState({ ...next, medStep: 'ask' });
                      onDone();
                    }
                  }}
                  style={{
                    minHeight: 86, borderRadius: 16,
                    background: '#fff', border: '3px solid #1A1A1A',
                    cursor: 'pointer',
                    display: 'flex', flexDirection: 'column',
                    alignItems: 'center', justifyContent: 'center', gap: 0,
                    boxShadow: '0 5px 0 #1A1A1A',
                  }}>
                  <span style={{ fontSize: 14, color: '#7C3AED', fontWeight: 700 }}>{ampm}</span>
                  <span style={{ fontSize: 34, fontWeight: 900 }}>{display}시</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    );
  }
}

Object.assign(window, { OnboardingApps, OnboardingMed });
