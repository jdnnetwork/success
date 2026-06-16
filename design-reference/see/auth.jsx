// auth.jsx — 로그인 / 회원가입 / 연결

function AuthLanding({ navigate }) {
  return (
    <div style={{
      height: '100%', background: '#FAF7F0',
      display: 'flex', flexDirection: 'column', padding: 24,
    }}>
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 18,
      }}>
        <div style={{
          width: 150, height: 150, borderRadius: 36, background: '#FFF1D6',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 12px 32px rgba(11,95,217,0.25)',
          border: '4px solid #1A1A1A',
          overflow: 'hidden',
        }}>
          {/* 어르신 일러스트 — 따뜻한 톤의 SVG */}
          <svg viewBox="0 0 120 120" width="130" height="130">
            {/* 배경 원 */}
            <circle cx="60" cy="60" r="54" fill="#FFE0B0"/>
            {/* 머리 (백발) */}
            <ellipse cx="60" cy="40" rx="26" ry="22" fill="#E8E8E8"/>
            <path d="M34 42c0-14 12-24 26-24s26 10 26 24c0-6-4-10-10-10-3 0-5 2-8 2s-5-2-8-2-5 2-8 2-5-2-8-2c-6 0-10 4-10 10z" fill="#C8C8C8"/>
            {/* 얼굴 */}
            <ellipse cx="60" cy="52" rx="22" ry="24" fill="#F5C99C"/>
            {/* 안경 — 어르신 상징 */}
            <circle cx="50" cy="52" r="7" fill="none" stroke="#1A1A1A" strokeWidth="2.5"/>
            <circle cx="70" cy="52" r="7" fill="none" stroke="#1A1A1A" strokeWidth="2.5"/>
            <line x1="57" y1="52" x2="63" y2="52" stroke="#1A1A1A" strokeWidth="2.5"/>
            {/* 눈동자 */}
            <circle cx="50" cy="52" r="2" fill="#1A1A1A"/>
            <circle cx="70" cy="52" r="2" fill="#1A1A1A"/>
            {/* 미소 */}
            <path d="M52 64 Q60 70 68 64" stroke="#1A1A1A" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
            {/* 볼터치 */}
            <circle cx="44" cy="60" r="3" fill="#F5A0A0" opacity="0.7"/>
            <circle cx="76" cy="60" r="3" fill="#F5A0A0" opacity="0.7"/>
            {/* 목 + 옷 */}
            <rect x="52" y="74" width="16" height="6" fill="#F5C99C"/>
            <path d="M30 120 Q30 90 60 86 Q90 90 90 120 z" fill="#0B5FD9"/>
            <circle cx="60" cy="100" r="3" fill="#FFF"/>
          </svg>
        </div>
        <div style={{ fontSize: 48, fontWeight: 900, color: '#1A1A1A', letterSpacing: '-0.03em' }}>
          잘보이네
        </div>
        <div style={{ fontSize: 20, color: '#4A4A4A', textAlign: 'center', fontWeight: 600, lineHeight: 1.5 }}>
          어르신을 위한<br/>크고 간단한 폰 화면
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingBottom: 12 }}>
        <button className="bigbtn bigbtn--primary" onClick={() => navigate('authPhone', { role: 'elder' })}>
          어르신으로 시작
        </button>
        <button className="bigbtn bigbtn--ghost" onClick={() => navigate('authPhone', { role: 'guardian' })}
          style={{ minHeight: 80, fontSize: 24 }}>
          가족 (보호자) 로그인
        </button>
      </div>
    </div>
  );
}

function AuthPhone({ role, navigate, setState, state }) {
  const [phone, setPhone] = React.useState('');
  const [step, setStep] = React.useState('phone');
  const [code, setCode] = React.useState('');

  const press = (n) => {
    if (step === 'phone') {
      if (phone.length >= 11) return;
      setPhone(phone + n);
    } else {
      if (code.length >= 4) return;
      const next = code + n;
      setCode(next);
      if (next.length === 4) {
        setTimeout(() => {
          if (role === 'guardian') {
            navigate('authConnect');
          } else {
            navigate('onbApps');
          }
        }, 400);
      }
    }
  };
  const back = () => {
    if (step === 'phone') setPhone(phone.slice(0, -1));
    else setCode(code.slice(0, -1));
  };

  const fmtPhone = (p) => {
    if (p.length <= 3) return p;
    if (p.length <= 7) return p.slice(0,3) + '-' + p.slice(3);
    return p.slice(0,3) + '-' + p.slice(3,7) + '-' + p.slice(7);
  };

  return (
    <div style={{
      height: '100%', background: '#FAF7F0',
      display: 'flex', flexDirection: 'column',
    }}>
      <ScreenHeader onBack={() => step === 'code' ? setStep('phone') : navigate('authLanding')}
        title={role === 'elder' ? '어르신 시작하기' : '보호자 로그인'}/>

      <div style={{
        flex: 1, padding: '20px 24px', display: 'flex',
        flexDirection: 'column', gap: 16,
      }}>
        {step === 'phone' ? (
          <>
            <div style={{
              fontSize: 26, fontWeight: 800, color: '#1A1A1A',
              letterSpacing: '-0.02em', lineHeight: 1.4,
            }}>
              전화번호를<br/>입력해 주세요
            </div>
            <div style={{ fontSize: 16, color: '#4A4A4A' }}>
              본인 확인을 위해 문자로 4자리 숫자를 보내드려요
            </div>
            <div style={{
              padding: '20px 16px', background: '#fff',
              border: '3px solid #1A1A1A', borderRadius: 18,
              fontSize: 32, fontWeight: 800,
              fontVariantNumeric: 'tabular-nums',
              minHeight: 70, display: 'flex', alignItems: 'center',
              color: phone ? '#1A1A1A' : '#999',
              letterSpacing: '0.02em',
            }}>
              {phone ? fmtPhone(phone) : '010-0000-0000'}
            </div>
            {phone.length === 11 && (
              <button className="bigbtn bigbtn--primary"
                onClick={() => setStep('code')} style={{ minHeight: 80 }}>
                인증번호 받기
              </button>
            )}
          </>
        ) : (
          <>
            <div style={{
              fontSize: 26, fontWeight: 800, color: '#1A1A1A',
              letterSpacing: '-0.02em', lineHeight: 1.4,
            }}>
              문자로 받은<br/>4자리 숫자를 입력
            </div>
            <div style={{ fontSize: 14, color: '#4A4A4A' }}>
              {fmtPhone(phone)}로 발송 · 힌트: 1234
            </div>
            <div style={{
              display: 'flex', gap: 12, justifyContent: 'center', padding: '12px 0',
            }}>
              {[0,1,2,3].map(i => (
                <div key={i} style={{
                  width: 64, height: 80, borderRadius: 14,
                  background: '#fff', border: '3px solid #1A1A1A',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 44, fontWeight: 900,
                }}>
                  {code[i] || ''}
                </div>
              ))}
            </div>
          </>
        )}

        <div style={{ flex: 1 }}/>

        {/* 큰 키패드 */}
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8,
        }}>
          {[1,2,3,4,5,6,7,8,9].map(n => (
            <button key={n} onClick={() => press(String(n))} style={{
              height: 64, borderRadius: 14, background: '#fff',
              border: '2px solid #1A1A1A', cursor: 'pointer',
              fontSize: 30, fontWeight: 800, boxShadow: '0 3px 0 #1A1A1A',
            }}>{n}</button>
          ))}
          <div/>
          <button onClick={() => press('0')} style={{
            height: 64, borderRadius: 14, background: '#fff',
            border: '2px solid #1A1A1A', cursor: 'pointer',
            fontSize: 30, fontWeight: 800, boxShadow: '0 3px 0 #1A1A1A',
          }}>0</button>
          <button onClick={back} style={{
            height: 64, borderRadius: 14, background: '#FAF7F0',
            border: '2px solid #1A1A1A', cursor: 'pointer',
            fontSize: 24, boxShadow: '0 3px 0 #1A1A1A',
          }}>⌫</button>
        </div>
      </div>
    </div>
  );
}

function AuthConnect({ navigate, state, setState }) {
  const [code, setCode] = React.useState('');

  return (
    <div style={{
      height: '100%', background: '#FAF7F0',
      display: 'flex', flexDirection: 'column',
    }}>
      <ScreenHeader onBack={() => navigate('authLanding')} title="가족 연결"/>
      <div style={{ flex: 1, padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'center', padding: '12px 0' }}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 16, fontSize: 40,
          }}>
            <span>👨‍💼</span>
            <span style={{ fontSize: 28 }}>━━</span>
            <span>👵</span>
          </div>
        </div>

        <div style={{ fontSize: 22, fontWeight: 800, lineHeight: 1.4 }}>
          어르신 폰에 표시된<br/>6자리 코드를 입력하세요
        </div>

        <div style={{
          background: '#0B5FD9', color: '#fff', borderRadius: 16,
          padding: '14px 16px', fontSize: 14, lineHeight: 1.5,
        }}>
          어르신 폰 → 설정 → 가족 연결 → 코드 발급<br/>
          <span style={{ opacity: .8 }}>(테스트: 384-921 입력)</span>
        </div>

        <div style={{
          display: 'flex', gap: 8, justifyContent: 'center', padding: '20px 0',
        }}>
          {[0,1,2,'-',3,4,5].map((i, k) => i === '-' ? (
            <div key={k} style={{ alignSelf: 'center', fontSize: 30, fontWeight: 800 }}>−</div>
          ) : (
            <input key={k} maxLength={1}
              value={code[i] || ''}
              onChange={e => {
                const ch = e.target.value.replace(/\D/g, '').slice(-1);
                const arr = code.split('');
                arr[i] = ch;
                const next = arr.join('').slice(0, 6);
                setCode(next);
                if (next.length === 6 && next === '384921') {
                  setTimeout(() => navigate('guardianHome'), 300);
                }
              }}
              style={{
                width: 44, height: 60, borderRadius: 12,
                background: '#fff', border: '3px solid #1A1A1A',
                fontSize: 32, fontWeight: 900, textAlign: 'center',
                fontFamily: 'inherit',
              }}/>
          ))}
        </div>

        <button onClick={() => {
          if (code === '384921' || code.length === 6) navigate('guardianHome');
        }}
          className="bigbtn bigbtn--primary"
          style={{ minHeight: 72, fontSize: 24,
            opacity: code.length === 6 ? 1 : 0.4,
            pointerEvents: code.length === 6 ? 'auto' : 'none' }}>
          연결하기
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { AuthLanding, AuthPhone, AuthConnect });
