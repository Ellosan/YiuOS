"use client";

import { useEffect, useMemo, useState } from "react";

type View =
  | "boot"
  | "lock"
  | "home"
  | "control"
  | "settings"
  | "about"
  | "privacy"
  | "recents"
  | "app";
type Accent = "orange" | "amber" | "ember";

const appIcons = [
  { name: "Phone", glyph: "☎", tone: "green" },
  { name: "Messages", glyph: "●", tone: "lime" },
  { name: "Camera", glyph: "◉", tone: "graphite" },
  { name: "Gallery", glyph: "✿", tone: "sunset" },
  { name: "Themes", glyph: "✦", tone: "orange" },
  { name: "Files", glyph: "⌁", tone: "blue" },
  { name: "Browser", glyph: "⌾", tone: "aqua" },
  { name: "Settings", glyph: "⚙", tone: "silver" },
];

const accentColors: Record<Accent, string> = {
  orange: "#ff7a18",
  amber: "#f5a000",
  ember: "#ef4f24",
};

export default function Home() {
  const [view, setView] = useState<View>("boot");
  const [dark, setDark] = useState(false);
  const [wifi, setWifi] = useState(true);
  const [bluetooth, setBluetooth] = useState(true);
  const [airplane, setAirplane] = useState(false);
  const [focus, setFocus] = useState(false);
  const [playing, setPlaying] = useState(true);
  const [accent, setAccent] = useState<Accent>("orange");
  const [brightness, setBrightness] = useState(72);
  const [volume, setVolume] = useState(48);
  const [now, setNow] = useState<Date | null>(null);
  const [toast, setToast] = useState("");
  const [activeApp, setActiveApp] = useState("Phone");
  const [recentApps, setRecentApps] = useState(["Settings", "Gallery", "Browser"]);
  const [phoneNumber, setPhoneNumber] = useState("");
  const [messageDraft, setMessageDraft] = useState("");
  const [messages, setMessages] = useState([
    "Welcome to YiuOS. Your encrypted space is ready.",
  ]);
  const [cameraFlash, setCameraFlash] = useState(false);
  const [privacyGuard, setPrivacyGuard] = useState(true);
  const [locationAccess, setLocationAccess] = useState(false);

  useEffect(() => {
    const update = () => setNow(new Date());
    update();
    const timer = window.setInterval(update, 30_000);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    const saved = window.localStorage.getItem("yiuos-preferences");
    const preferenceTimer = window.setTimeout(() => {
      if (saved) {
        try {
          const preferences = JSON.parse(saved) as {
            accent?: string;
            dark?: boolean;
            brightness?: number;
            volume?: number;
          };
          if (preferences.accent && preferences.accent in accentColors) {
            setAccent(preferences.accent as Accent);
          } else {
            setAccent("orange");
          }
          if (typeof preferences.dark === "boolean") setDark(preferences.dark);
          if (typeof preferences.brightness === "number") setBrightness(preferences.brightness);
          if (typeof preferences.volume === "number") setVolume(preferences.volume);
        } catch {
          window.localStorage.removeItem("yiuos-preferences");
        }
      }
    }, 0);
    const bootTimer = window.setTimeout(() => setView("lock"), 1450);
    return () => {
      window.clearTimeout(preferenceTimer);
      window.clearTimeout(bootTimer);
    };
  }, []);

  useEffect(() => {
    window.localStorage.setItem(
      "yiuos-preferences",
      JSON.stringify({ accent, dark, brightness, volume }),
    );
  }, [accent, dark, brightness, volume]);

  useEffect(() => {
    if (!toast) return;
    const timer = window.setTimeout(() => setToast(""), 1800);
    return () => window.clearTimeout(timer);
  }, [toast]);

  const time = now
    ? new Intl.DateTimeFormat("en", {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      }).format(now)
    : "12:38";

  const date = now
    ? new Intl.DateTimeFormat("en", {
        weekday: "long",
        month: "long",
        day: "numeric",
      }).format(now)
    : "Thursday, July 23";

  const accentStyle = useMemo(
    () =>
      ({
        "--accent": accentColors[accent],
        "--screen-light": `${0.82 + brightness / 500}`,
      }) as React.CSSProperties,
    [accent, brightness],
  );

  function launchApp(name: string) {
    if (name === "Settings") {
      setView("settings");
      return;
    }
    if (name === "Themes") {
      const next: Record<Accent, Accent> = {
        orange: "amber",
        amber: "ember",
        ember: "orange",
      };
      setAccent(next[accent]);
      setToast("Accent changed");
      return;
    }
    setActiveApp(name);
    setRecentApps((current) => [name, ...current.filter((app) => app !== name)].slice(0, 3));
    setView("app");
  }

  function sendMessage() {
    const trimmed = messageDraft.trim();
    if (!trimmed) return;
    setMessages((current) => [...current, trimmed]);
    setMessageDraft("");
    setToast("Message kept on this device");
  }

  return (
    <main
      className={`experience ${dark ? "is-dark" : ""}`}
      style={accentStyle}
    >
      <div className="ambient ambient-one" />
      <div className="ambient ambient-two" />

      <section className="story">
        <div className="wordmark" aria-label="YiuOS">
          <span className="brand-mark">Y</span>
          <span>YiuOS</span>
          <small>ONE</small>
        </div>
        <p className="eyebrow">ANDROID, REIMAGINED</p>
        <h1>Open at the core.<br />Beautiful by nature.</h1>
        <p className="intro">
          A community-first mobile OS with privacy controls, deep theming, and a
          fluid interface that feels unmistakably yours.
        </p>
        <div className="promise-grid">
          <article>
            <span>01</span>
            <strong>Pure control</strong>
            <p>No bloat. No ads. Every permission is yours to command.</p>
          </article>
          <article>
            <span>02</span>
            <strong>Living design</strong>
            <p>Color, depth, and motion adapt around your wallpaper.</p>
          </article>
        </div>
        <button className="try-button" onClick={() => setView("home")}>
          Try YiuOS <span>→</span>
        </button>
        <div className="build-status">
          <span className="status-light" />
          <div>
            <strong>Prototype 0.2 is live</strong>
            <small>Core UI · System apps · Privacy layer</small>
          </div>
        </div>
      </section>

      <section className="device-stage" aria-label="Interactive YiuOS demo">
        <div className="phone">
          <div className="speaker" />
          <div className="screen">
            <div className="wallpaper">
              <span className="wallpaper-orb orb-a" />
              <span className="wallpaper-orb orb-b" />
              <span className="wallpaper-orb orb-c" />
            </div>

            {view === "boot" && (
              <div className="view boot-view">
                <div className="boot-logo">Y</div>
                <strong>YiuOS</strong>
                <div className="boot-progress"><span /></div>
                <small>POWERED BY OPEN ANDROID</small>
              </div>
            )}

            {view === "lock" && (
              <div className="view lock-view">
                <StatusBar
                  time={time}
                  onControl={() => setView("control")}
                />
                <div className="lock-copy">
                  <p>{date}</p>
                  <h2>{time}</h2>
                  <div className="weather-pill">
                    <span>☀</span> 29° <small>Kozani</small>
                  </div>
                </div>
                <div className="notifications">
                  <article className="notification">
                    <div className="notification-icon message-icon">●</div>
                    <div>
                      <strong>Messages</strong>
                      <p>YiuOS setup is complete. Welcome home.</p>
                    </div>
                    <span>now</span>
                  </article>
                  <article className="notification quiet">
                    <div className="notification-icon shield-icon">✓</div>
                    <div>
                      <strong>Privacy dashboard</strong>
                      <p>No apps accessed your data today.</p>
                    </div>
                    <span>8m</span>
                  </article>
                </div>
                <div className="lock-actions">
                  <button aria-label="Flashlight" onClick={() => setToast("Flashlight on")}>
                    ◒
                  </button>
                  <button
                    className="unlock-button"
                    onClick={() => setView("home")}
                  >
                    Swipe up to unlock
                  </button>
                  <button aria-label="Camera" onClick={() => launchApp("Camera")}>
                    ◉
                  </button>
                </div>
              </div>
            )}

            {view === "home" && (
              <div className="view home-view">
                <StatusBar
                  time={time}
                  onControl={() => setView("control")}
                />
                <div className="island" onClick={() => setView("control")}>
                  <span className="pulse-dot" />
                  YiuOS ready
                </div>
                <div className="widget-row">
                  <article className="weather-widget">
                    <div>
                      <span>Kozani</span>
                      <strong>29°</strong>
                    </div>
                    <div className="sun">☀</div>
                    <p>Clear · Feels like 28°</p>
                  </article>
                  <article className="date-widget">
                    <span>THU</span>
                    <strong>{now?.getDate() ?? 23}</strong>
                    <p>No events today</p>
                  </article>
                </div>

                <div className="app-grid">
                  {appIcons.map((app) => (
                    <button
                      className="app"
                      key={app.name}
                      onClick={() => launchApp(app.name)}
                      aria-label={`Open ${app.name}`}
                    >
                      <span className={`app-icon ${app.tone}`}>{app.glyph}</span>
                      <span>{app.name}</span>
                    </button>
                  ))}
                </div>

                <div className="page-dots">
                  <span className="active" aria-hidden="true" />
                  <button onClick={() => setView("recents")} aria-label="Open recent apps" />
                </div>

                <div className="dock">
                  {["☎", "●", "◎", "♫"].map((glyph, index) => (
                    <button
                      key={glyph + index}
                      onClick={() => launchApp(["Phone", "Messages", "Browser", "Music"][index])}
                      aria-label={["Phone", "Messages", "Browser", "Music"][index]}
                    >
                      {glyph}
                    </button>
                  ))}
                </div>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "control" && (
              <div className="view panel-view">
                <StatusBar time={time} onControl={() => setView("home")} />
                <div className="panel-title">
                  <div>
                    <p>{date}</p>
                    <h2>Control Center</h2>
                  </div>
                  <button onClick={() => setView("home")} aria-label="Close">
                    ×
                  </button>
                </div>
                <div className="control-grid">
                  <ToggleTile
                    active={wifi}
                    icon="⌁"
                    title="Wi-Fi"
                    subtitle={wifi ? "YiuNet 5G" : "Off"}
                    onClick={() => setWifi(!wifi)}
                  />
                  <ToggleTile
                    active={bluetooth}
                    icon="ᛒ"
                    title="Bluetooth"
                    subtitle={bluetooth ? "On" : "Off"}
                    onClick={() => setBluetooth(!bluetooth)}
                  />
                  <ToggleTile
                    active={airplane}
                    icon="✈"
                    title="Airplane mode"
                    subtitle={airplane ? "On" : "Off"}
                    onClick={() => setAirplane(!airplane)}
                  />
                  <ToggleTile
                    active={focus}
                    icon="☾"
                    title="Focus"
                    subtitle={focus ? "Personal" : "Off"}
                    onClick={() => setFocus(!focus)}
                  />
                </div>
                <div className="sliders">
                  <label>
                    <span>☀</span>
                    <input
                      type="range"
                      min="10"
                      max="100"
                      value={brightness}
                      onChange={(event) => setBrightness(Number(event.target.value))}
                      aria-label="Brightness"
                    />
                  </label>
                  <label>
                    <span>◕</span>
                    <input
                      type="range"
                      min="0"
                      max="100"
                      value={volume}
                      onChange={(event) => setVolume(Number(event.target.value))}
                      aria-label="Volume"
                    />
                  </label>
                </div>
                <article className="now-playing">
                  <div className="album-art">Y</div>
                  <div>
                    <span>NOW PLAYING</span>
                    <strong>Open Skies</strong>
                    <p>Yiu Sound System</p>
                  </div>
                  <button
                    onClick={() => setPlaying(!playing)}
                    aria-label={playing ? "Pause" : "Play"}
                  >
                    {playing ? "Ⅱ" : "▶"}
                  </button>
                </article>
                <div className="quick-actions">
                  <button onClick={() => setDark(!dark)}>
                    <span>{dark ? "☀" : "☾"}</span>
                    {dark ? "Light" : "Dark"}
                  </button>
                  <button onClick={() => setView("settings")}>
                    <span>⚙</span>
                    Settings
                  </button>
                  <button onClick={() => setView("about")}>
                    <span>Y</span>
                    About
                  </button>
                </div>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "settings" && (
              <div className="view settings-view">
                <StatusBar time={time} onControl={() => setView("control")} />
                <header className="app-header">
                  <button onClick={() => setView("home")} aria-label="Back">
                    ‹
                  </button>
                  <h2>Settings</h2>
                  <span />
                </header>
                <div className="profile-card">
                  <div className="avatar">Y</div>
                  <div>
                    <strong>Your Yiu</strong>
                    <p>Sync off · Private by default</p>
                  </div>
                  <span>›</span>
                </div>
                <div className="settings-group">
                  <button onClick={() => setWifi(!wifi)}>
                    <span className="setting-icon orange">⌁</span>
                    <div><strong>Wi-Fi</strong><small>{wifi ? "YiuNet 5G" : "Off"}</small></div>
                    <b>›</b>
                  </button>
                  <button onClick={() => setBluetooth(!bluetooth)}>
                    <span className="setting-icon amber">ᛒ</span>
                    <div><strong>Bluetooth</strong><small>{bluetooth ? "On" : "Off"}</small></div>
                    <b>›</b>
                  </button>
                </div>
                <div className="settings-group">
                  <button onClick={() => setDark(!dark)}>
                    <span className="setting-icon graphite">◐</span>
                    <div><strong>Display & style</strong><small>{dark ? "Midnight" : "Cloud"}</small></div>
                    <b>›</b>
                  </button>
                  <button onClick={() => setView("privacy")}>
                    <span className="setting-icon green">✓</span>
                    <div><strong>Privacy & permissions</strong><small>Protected</small></div>
                    <b>›</b>
                  </button>
                  <button onClick={() => setView("about")}>
                    <span className="setting-icon ember">Y</span>
                    <div><strong>About YiuOS</strong><small>Version 1.0 · Aurora</small></div>
                    <b>›</b>
                  </button>
                </div>
                <div className="accent-card">
                  <div>
                    <strong>Dynamic color</strong>
                    <p>Choose how YiuOS feels.</p>
                  </div>
                  <div className="swatches">
                    {(["orange", "amber", "ember"] as Accent[]).map((color) => (
                      <button
                        key={color}
                        className={`${color} ${accent === color ? "selected" : ""}`}
                        aria-label={`Use ${color} accent`}
                        onClick={() => setAccent(color)}
                      />
                    ))}
                  </div>
                </div>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "about" && (
              <div className="view about-view">
                <StatusBar time={time} onControl={() => setView("control")} />
                <header className="app-header">
                  <button onClick={() => setView("settings")} aria-label="Back">
                    ‹
                  </button>
                  <h2>About YiuOS</h2>
                  <span />
                </header>
                <div className="about-hero">
                  <div className="about-logo">Y</div>
                  <p>YiuOS</p>
                  <h2>One · Aurora</h2>
                  <span>Android, made yours.</span>
                </div>
                <div className="version-card">
                  <div><span>YiuOS version</span><strong>1.0</strong></div>
                  <div><span>Android version</span><strong>16</strong></div>
                  <div><span>Security update</span><strong>July 2026</strong></div>
                  <div><span>Build</span><strong>AURORA.2607</strong></div>
                </div>
                <p className="opensource-note">
                  Built on the spirit of open Android: transparent, repairable,
                  and shaped by its community.
                </p>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "privacy" && (
              <div className="view settings-view privacy-view">
                <StatusBar time={time} onControl={() => setView("control")} />
                <header className="app-header">
                  <button onClick={() => setView("settings")} aria-label="Back">
                    ‹
                  </button>
                  <h2>Privacy</h2>
                  <span />
                </header>
                <div className="privacy-score">
                  <div className="score-ring"><span>96</span></div>
                  <div>
                    <strong>Your data stays yours</strong>
                    <p>No unusual app activity detected.</p>
                  </div>
                </div>
                <div className="permission-timeline">
                  <p>RECENT PERMISSION ACTIVITY</p>
                  <article><span className="privacy-dot camera" /><div><strong>Camera</strong><small>Camera · 2 minutes ago</small></div><b>Only while in use</b></article>
                  <article><span className="privacy-dot mic" /><div><strong>Microphone</strong><small>No access today</small></div><b>Blocked</b></article>
                  <article><span className="privacy-dot location" /><div><strong>Location</strong><small>Weather · Approximate</small></div><b>Approximate</b></article>
                </div>
                <div className="privacy-toggles">
                  <button onClick={() => setPrivacyGuard(!privacyGuard)}>
                    <div><strong>Privacy Guard</strong><small>Warn when apps track activity</small></div>
                    <span className={`switch ${privacyGuard ? "on" : ""}`} />
                  </button>
                  <button onClick={() => setLocationAccess(!locationAccess)}>
                    <div><strong>Location access</strong><small>System-wide permission</small></div>
                    <span className={`switch ${locationAccess ? "on" : ""}`} />
                  </button>
                </div>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "recents" && (
              <div className="view recents-view">
                <StatusBar time={time} onControl={() => setView("control")} />
                <div className="recents-title">
                  <div><small>MEMORY AVAILABLE</small><strong>5.8 GB</strong></div>
                  <button onClick={() => { setRecentApps([]); setToast("All clear"); }}>Clear all</button>
                </div>
                <div className="recent-cards">
                  {recentApps.length ? recentApps.map((app, index) => (
                    <button
                      key={app}
                      className={`recent-card recent-${index}`}
                      onClick={() => launchApp(app)}
                    >
                      <span className="recent-app-icon">{app.slice(0, 1)}</span>
                      <strong>{app}</strong>
                      <div className="recent-preview">
                        <span />
                        <span />
                        <span />
                      </div>
                    </button>
                  )) : (
                    <div className="empty-recents">
                      <span>✓</span>
                      <strong>You’re all clear</strong>
                      <p>No recent apps are using memory.</p>
                    </div>
                  )}
                </div>
                <GestureBar onHome={() => setView("home")} />
              </div>
            )}

            {view === "app" && (
              <SystemApp
                name={activeApp}
                time={time}
                phoneNumber={phoneNumber}
                setPhoneNumber={setPhoneNumber}
                messageDraft={messageDraft}
                setMessageDraft={setMessageDraft}
                messages={messages}
                sendMessage={sendMessage}
                playing={playing}
                setPlaying={setPlaying}
                cameraFlash={cameraFlash}
                setCameraFlash={setCameraFlash}
                onBack={() => setView("home")}
                onControl={() => setView("control")}
                onToast={setToast}
              />
            )}

            {toast && <div className="toast">{toast}</div>}
          </div>
        </div>
        <p className="demo-hint">Tap the phone to explore · Every control works</p>
      </section>
    </main>
  );
}

function StatusBar({
  time,
  onControl,
}: {
  time: string;
  onControl: () => void;
}) {
  return (
    <div className="status-bar">
      <span>{time}</span>
      <button onClick={onControl} aria-label="Open Control Center">
        <span className="signal">▮▮▮</span>
        <span>⌁</span>
        <span className="battery">82</span>
      </button>
    </div>
  );
}

function GestureBar({ onHome }: { onHome: () => void }) {
  return (
    <button className="gesture-bar" onClick={onHome} aria-label="Go home">
      <span />
    </button>
  );
}

function ToggleTile({
  active,
  icon,
  title,
  subtitle,
  onClick,
}: {
  active: boolean;
  icon: string;
  title: string;
  subtitle: string;
  onClick: () => void;
}) {
  return (
    <button className={`toggle-tile ${active ? "active" : ""}`} onClick={onClick}>
      <span>{icon}</span>
      <div><strong>{title}</strong><small>{subtitle}</small></div>
    </button>
  );
}

function SystemApp({
  name,
  time,
  phoneNumber,
  setPhoneNumber,
  messageDraft,
  setMessageDraft,
  messages,
  sendMessage,
  playing,
  setPlaying,
  cameraFlash,
  setCameraFlash,
  onBack,
  onControl,
  onToast,
}: {
  name: string;
  time: string;
  phoneNumber: string;
  setPhoneNumber: (value: string) => void;
  messageDraft: string;
  setMessageDraft: (value: string) => void;
  messages: string[];
  sendMessage: () => void;
  playing: boolean;
  setPlaying: (value: boolean) => void;
  cameraFlash: boolean;
  setCameraFlash: (value: boolean) => void;
  onBack: () => void;
  onControl: () => void;
  onToast: (message: string) => void;
}) {
  const [browserQuery, setBrowserQuery] = useState("");
  const [browserResult, setBrowserResult] = useState(false);

  return (
    <div className={`view system-app-view app-${name.toLowerCase()}`}>
      <StatusBar time={time} onControl={onControl} />
      <header className="app-header">
        <button onClick={onBack} aria-label="Back">‹</button>
        <h2>{name}</h2>
        <button className="header-action" onClick={() => onToast(`${name} menu`)}>
          •••
        </button>
      </header>

      {name === "Phone" && (
        <div className="dialer">
          <div className="dial-number">
            <strong>{phoneNumber || "Enter a number"}</strong>
            <small>{phoneNumber ? "Mobile" : "Yiu Phone"}</small>
          </div>
          <div className="dial-pad">
            {["1","2","3","4","5","6","7","8","9","*","0","#"].map((number) => (
              <button key={number} onClick={() => setPhoneNumber(phoneNumber + number)}>
                <strong>{number}</strong>
                <small>{({2:"ABC",3:"DEF",4:"GHI",5:"JKL",6:"MNO",7:"PQRS",8:"TUV",9:"WXYZ"} as Record<string,string>)[number] ?? ""}</small>
              </button>
            ))}
          </div>
          <div className="dial-actions">
            <button className="call-button" onClick={() => onToast(phoneNumber ? `Calling ${phoneNumber}` : "Enter a number")}>☎</button>
            <button aria-label="Delete digit" onClick={() => setPhoneNumber(phoneNumber.slice(0, -1))}>⌫</button>
          </div>
        </div>
      )}

      {name === "Messages" && (
        <div className="messages-app">
          <div className="contact-bar">
            <div className="contact-avatar">Y</div>
            <div><strong>Yiu Community</strong><small>Encrypted conversation</small></div>
          </div>
          <div className="chat-stream">
            {messages.map((message, index) => (
              <p key={`${message}-${index}`} className={index ? "outgoing" : ""}>{message}</p>
            ))}
          </div>
          <div className="message-composer">
            <input
              value={messageDraft}
              onChange={(event) => setMessageDraft(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") sendMessage();
              }}
              placeholder="Message"
              aria-label="Message"
            />
            <button onClick={sendMessage} aria-label="Send message">↑</button>
          </div>
        </div>
      )}

      {name === "Camera" && (
        <div className="camera-app">
          <div className="camera-tools">
            <button onClick={() => setCameraFlash(!cameraFlash)}>{cameraFlash ? "⚡" : "♢"}</button>
            <span>AI scene</span>
            <button onClick={() => onToast("Camera settings")}>⚙</button>
          </div>
          <div className="viewfinder">
            <div className="focus-frame"><span /></div>
            <small>29° · Kozani</small>
          </div>
          <div className="camera-modes"><span>PORTRAIT</span><strong>PHOTO</strong><span>VIDEO</span></div>
          <div className="shutter-row">
            <button className="last-photo" onClick={() => onToast("Gallery opened")}>✿</button>
            <button className="shutter" onClick={() => onToast("Photo captured")}><span /></button>
            <button className="flip-camera" onClick={() => onToast("Camera flipped")}>↻</button>
          </div>
        </div>
      )}

      {name === "Gallery" && (
        <div className="gallery-app">
          <div className="gallery-heading"><div><small>JULY 2026</small><strong>Moments</strong></div><button>⌕</button></div>
          <div className="photo-grid">
            {["violet","sunset","sky","night","peach","mint","lake","aurora"].map((tone, index) => (
              <button key={tone} className={`photo ${tone}`} onClick={() => onToast(`Photo ${index + 1} selected`)}>
                <span>{index === 0 ? "TODAY" : ""}</span>
              </button>
            ))}
          </div>
          <div className="gallery-tabs"><strong>Photos</strong><span>Albums</span><span>Discover</span></div>
        </div>
      )}

      {name === "Files" && (
        <div className="files-app">
          <div className="storage-card">
            <div className="storage-ring"><span>38%</span></div>
            <div><small>DEVICE STORAGE</small><strong>48.6 GB of 128 GB</strong><p><i /> Apps <i /> Media <i /> System</p></div>
          </div>
          <div className="file-categories">
            {[
              ["▣","Images","1,284 items"],
              ["▶","Videos","36 items"],
              ["♫","Audio","118 items"],
              ["⇩","Downloads","24 items"],
            ].map(([icon,title,detail]) => (
              <button key={title} onClick={() => onToast(`${title} opened`)}><span>{icon}</span><div><strong>{title}</strong><small>{detail}</small></div><b>›</b></button>
            ))}
          </div>
          <div className="recent-files"><p>RECENT FILES</p><article><span>Y</span><div><strong>YiuOS-roadmap.pdf</strong><small>2.4 MB · Today</small></div><button>•••</button></article></div>
        </div>
      )}

      {name === "Browser" && (
        <div className="browser-app">
          <form
            className="browser-search"
            onSubmit={(event) => {
              event.preventDefault();
              if (browserQuery.trim()) setBrowserResult(true);
            }}
          >
            <span>⌾</span>
            <input value={browserQuery} onChange={(event) => setBrowserQuery(event.target.value)} placeholder="Search privately" aria-label="Search privately" />
            <button type="submit">→</button>
          </form>
          {browserResult ? (
            <div className="search-result">
              <span>PRIVATE RESULT</span>
              <h3>{browserQuery}</h3>
              <p>This concept browser keeps searches on-device and blocks trackers by default.</p>
              <button onClick={() => setBrowserResult(false)}>New search</button>
            </div>
          ) : (
            <>
              <div className="browser-brand"><div>Y</div><strong>Browse without being watched.</strong><p>Tracker blocking is active.</p></div>
              <div className="speed-dials">
                {["Docs","Community","Themes","Updates"].map((item) => <button key={item} onClick={() => { setBrowserQuery(item); setBrowserResult(true); }}><span>{item.slice(0,1)}</span>{item}</button>)}
              </div>
            </>
          )}
          <div className="browser-toolbar"><button>‹</button><button>›</button><button>＋</button><button>▢</button><button>•••</button></div>
        </div>
      )}

      {name === "Music" && (
        <div className="music-app">
          <div className="music-art"><span>Y</span><i /></div>
          <div className="track-info"><small>NOW PLAYING FROM YIU MIX</small><h3>Open Skies</h3><p>Yiu Sound System</p></div>
          <input type="range" min="0" max="100" defaultValue="42" aria-label="Track progress" />
          <div className="track-time"><span>1:48</span><span>4:12</span></div>
          <div className="music-controls"><button>↶</button><button>◀</button><button className="play-large" onClick={() => setPlaying(!playing)}>{playing ? "Ⅱ" : "▶"}</button><button>▶</button><button>↷</button></div>
          <div className="sound-badge">HI-RES · LOSSLESS</div>
        </div>
      )}

      {!["Phone","Messages","Camera","Gallery","Files","Browser","Music"].includes(name) && (
        <div className="generic-app">
          <div>{name.slice(0,1)}</div>
          <h3>{name}</h3>
          <p>This YiuOS system app is being prepared for the next build.</p>
          <button onClick={onBack}>Return home</button>
        </div>
      )}

      <GestureBar onHome={onBack} />
    </div>
  );
}
