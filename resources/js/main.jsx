import React, { useEffect, useMemo, useRef, useState } from 'react';
import { createRoot } from 'react-dom/client';
import {
  ArrowUp,
  Bot,
  ChevronDown,
  ExternalLink,
  Facebook,
  Github,
  GitCommit,
  Mail,
  Menu,
  Phone,
  Play,
  Send,
  Smartphone,
  X,
} from 'lucide-react';
import '../css/app.css';

const profile = '/assets/ven.jpg';

function Nav() {
  const [open, setOpen] = useState(false);
  const links = ['home', 'about', 'skills', 'projects', 'game', 'github', 'education', 'contact'];

  useEffect(() => {
    document.body.classList.toggle('menu-open', open);
    return () => document.body.classList.remove('menu-open');
  }, [open]);

  return (
    <nav className="site-nav" aria-label="Main navigation">
      <button className="icon-button" type="button" aria-label="Toggle menu" aria-expanded={open} onClick={() => setOpen(!open)}>
        <Menu size={22} className={open ? 'rotate' : ''} />
      </button>
      <ul className={open ? 'active' : ''}>
        {links.map((link) => (
          <li key={link}>
            <a href={`#${link}`} onClick={() => setOpen(false)}>
              {link[0].toUpperCase() + link.slice(1)}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}

function TypingText() {
  const words = useMemo(() => ['UX Designer | BSIT Student', 'Mobile & Web Developer', 'Firebase - Laravel - Django - React'], []);
  const [text, setText] = useState('');
  const index = useRef(0);
  const char = useRef(0);
  const deleting = useRef(false);

  useEffect(() => {
    let timer;
    const tick = () => {
      const current = words[index.current];
      char.current += deleting.current ? -1 : 1;
      setText(current.slice(0, char.current));

      if (!deleting.current && char.current === current.length) {
        deleting.current = true;
        timer = setTimeout(tick, 1500);
      } else if (deleting.current && char.current === 0) {
        deleting.current = false;
        index.current = (index.current + 1) % words.length;
        timer = setTimeout(tick, 300);
      } else {
        timer = setTimeout(tick, deleting.current ? 40 : 80);
      }
    };

    tick();
    return () => clearTimeout(timer);
  }, [words]);

  return <div className="typing-text">{text}</div>;
}

function Section({ id, title, children }) {
  return (
    <section id={id} className="content-section section-hidden">
      <h2>{title}</h2>
      {children}
    </section>
  );
}

function SkillGroup({ title, items }) {
  return (
    <div className="skill-group">
      <h3>{title}</h3>
      <ul className="chips">
        {items.map((item) => <li key={item}>{item}</li>)}
      </ul>
    </div>
  );
}

function ProjectCard({ title, description, note, tags, url, badge }) {
  return (
    <article className="project-card">
      <div className="project-title-row">
        <h3>{title}</h3>
        {badge && <span className="badge">{badge}</span>}
      </div>
      <p>{description}</p>
      {note && <p>{note}</p>}
      <div className="tag-row">
        {tags.map((tag) => <span key={tag}>{tag}</span>)}
      </div>
      {url && (
        <a className="demo-link" href={url} target="_blank" rel="noreferrer">
          <ExternalLink size={14} /> Live Demo <small>(static preview)</small>
        </a>
      )}
    </article>
  );
}

function SnakeGame() {
  const size = 16;
  const initialSnake = useMemo(() => [{ x: 8, y: 8 }, { x: 7, y: 8 }, { x: 6, y: 8 }], []);
  const [snake, setSnake] = useState(initialSnake);
  const [apple, setApple] = useState({ x: 12, y: 8 });
  const [direction, setDirection] = useState({ x: 1, y: 0 });
  const directionRef = useRef(direction);
  const [score, setScore] = useState(0);
  const [best, setBest] = useState(0);
  const [running, setRunning] = useState(false);
  const [playing, setPlaying] = useState(false);
  const [gameOver, setGameOver] = useState(false);

  useEffect(() => {
    directionRef.current = direction;
  }, [direction]);

  const placeApple = (body) => {
    const openCells = [];
    for (let y = 0; y < size; y += 1) {
      for (let x = 0; x < size; x += 1) {
        if (!body.some((part) => part.x === x && part.y === y)) openCells.push({ x, y });
      }
    }
    return openCells[Math.floor(Math.random() * openCells.length)] ?? { x: 0, y: 0 };
  };

  const resetGame = () => {
    setSnake(initialSnake);
    setApple({ x: 12, y: 8 });
    setDirection({ x: 1, y: 0 });
    directionRef.current = { x: 1, y: 0 };
    setScore(0);
    setGameOver(false);
    setPlaying(true);
    setRunning(true);
  };

  const stopGame = () => {
    setRunning(false);
    setPlaying(false);
  };

  const turn = (next) => {
    if (!playing) return;
    const current = directionRef.current;
    if (current.x + next.x === 0 && current.y + next.y === 0) return;
    directionRef.current = next;
    setDirection(next);
    setRunning(true);
  };

  useEffect(() => {
    const onKeyDown = (event) => {
      const activeTag = document.activeElement?.tagName;
      if (activeTag === 'INPUT' || activeTag === 'TEXTAREA') return;

      const key = event.key.toLowerCase();
      const gameKeys = ['arrowup', 'arrowdown', 'arrowleft', 'arrowright', 'w', 'a', 's', 'd', ' ', 'p', 'r', 'enter'];
      if (!gameKeys.includes(key) || !playing) return;

      event.preventDefault();

      if (key === 'arrowup' || key === 'w') turn({ x: 0, y: -1 });
      if (key === 'arrowdown' || key === 's') turn({ x: 0, y: 1 });
      if (key === 'arrowleft' || key === 'a') turn({ x: -1, y: 0 });
      if (key === 'arrowright' || key === 'd') turn({ x: 1, y: 0 });
      if (key === ' ' || key === 'p') setRunning((value) => !value);
      if (key === 'r' || key === 'enter') resetGame();
    };

    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [playing]);

  useEffect(() => {
    if (!running || gameOver) return undefined;

    const timer = window.setInterval(() => {
      setSnake((currentSnake) => {
        const head = currentSnake[0];
        const nextHead = {
          x: head.x + directionRef.current.x,
          y: head.y + directionRef.current.y,
        };
        const hitWall = nextHead.x < 0 || nextHead.x >= size || nextHead.y < 0 || nextHead.y >= size;
        const hitSelf = currentSnake.some((part) => part.x === nextHead.x && part.y === nextHead.y);

        if (hitWall || hitSelf) {
          setGameOver(true);
          setRunning(false);
          setBest((value) => Math.max(value, score));
          return currentSnake;
        }

        const ateApple = nextHead.x === apple.x && nextHead.y === apple.y;
        const nextSnake = ateApple ? [nextHead, ...currentSnake] : [nextHead, ...currentSnake.slice(0, -1)];

        if (ateApple) {
          setScore((value) => {
            const nextScore = value + 1;
            setBest((bestValue) => Math.max(bestValue, nextScore));
            return nextScore;
          });
          setApple(placeApple(nextSnake));
        }

        return nextSnake;
      });
    }, Math.max(80, 160 - score * 4));

    return () => window.clearInterval(timer);
  }, [running, gameOver, apple, score]);

  return (
    <Section id="game" title="Mini Game">
      <div className="game-panel">
        <div className="game-header">
          <div>
            <p className="eyebrow">Play inside the portfolio</p>
            <h3>Snake Apple Run</h3>
          </div>
          <div className="score-board">
            <span>Score <strong>{score}</strong></span>
            <span>Best <strong>{best}</strong></span>
          </div>
        </div>

        <div className="snake-board" role="application" aria-label="Snake game board" tabIndex="0">
          {Array.from({ length: size * size }).map((_, index) => {
            const x = index % size;
            const y = Math.floor(index / size);
            const isHead = snake[0].x === x && snake[0].y === y;
            const isSnake = snake.some((part) => part.x === x && part.y === y);
            const isApple = apple.x === x && apple.y === y;
            return <span className={`${isHead ? 'snake-head' : ''} ${isSnake ? 'snake-cell' : ''} ${isApple ? 'apple-cell' : ''}`} key={`${x}-${y}`} />;
          })}
          {!playing && !gameOver && <div className="game-overlay"><Play size={28} /> Press Start</div>}
          {playing && !running && !gameOver && <div className="game-overlay">Paused<br /><small>Press Resume</small></div>}
          {gameOver && <div className="game-overlay">Game Over<br /><small>Press Restart</small></div>}
        </div>

        <div className="game-controls">
          <button type="button" onClick={resetGame}>{gameOver ? 'Restart' : 'Start'}</button>
          <button type="button" onClick={() => setRunning((value) => !value)} disabled={gameOver || !playing}>{running ? 'Pause' : 'Resume'}</button>
          <button type="button" onClick={stopGame} disabled={!playing}>Stop Playing</button>
        </div>
        <p className="game-description">
          Built with React hooks for game state and movement timing, CSS Grid for the board, and browser keyboard events for snake control.
        </p>
      </div>
    </Section>
  );
}

function formatEventDate(dateString) {
  return new Intl.DateTimeFormat('en', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(new Date(dateString));
}

function describeGitHubEvent(event) {
  const repo = event.repo?.name ?? 'GitHub';

  if (event.type === 'PushEvent') {
    const count = event.payload?.commits?.length ?? 0;
    return `Pushed ${count} ${count === 1 ? 'commit' : 'commits'} to ${repo}`;
  }

  if (event.type === 'CreateEvent') {
    return `Created ${event.payload?.ref_type ?? 'item'} in ${repo}`;
  }

  if (event.type === 'PullRequestEvent') {
    return `${event.payload?.action ?? 'Updated'} pull request in ${repo}`;
  }

  if (event.type === 'IssuesEvent') {
    return `${event.payload?.action ?? 'Updated'} issue in ${repo}`;
  }

  if (event.type === 'WatchEvent') {
    return `Starred ${repo}`;
  }

  if (event.type === 'ForkEvent') {
    return `Forked ${repo}`;
  }

  return `${event.type.replace('Event', '')} in ${repo}`;
}

function GitHubActivity() {
  const username = 'haruto-web';
  const [events, setEvents] = useState([]);
  const [repos, setRepos] = useState([]);
  const [status, setStatus] = useState('loading');
  const [repoStatus, setRepoStatus] = useState('loading');

  useEffect(() => {
    const controller = new AbortController();

    const loadActivity = () => fetch(`https://api.github.com/users/${username}/events/public?t=${Date.now()}`, {
      cache: 'no-store',
      headers: {
        Accept: 'application/vnd.github+json',
        'Cache-Control': 'no-cache',
      },
      signal: controller.signal,
    })
      .then((response) => {
        if (!response.ok) throw new Error('GitHub activity is unavailable right now.');
        return response.json();
      })
      .then((data) => {
        const meaningfulEvents = Array.isArray(data)
          ? data.filter((event) => {
            const hasCommit = event.type !== 'PushEvent' || (event.payload?.commits?.length ?? 0) > 0;
            const isBranchCreation = event.type === 'CreateEvent' && event.payload?.ref_type === 'branch';
            return hasCommit && !isBranchCreation;
          })
          : [];
        setEvents(meaningfulEvents.slice(0, 6));
        setStatus('ready');
      })
      .catch((error) => {
        if (error.name !== 'AbortError') setStatus('error');
      });

    const loadRepos = () => fetch(`https://api.github.com/users/${username}/repos?sort=updated&per_page=8&t=${Date.now()}`, {
      cache: 'no-store',
      headers: {
        Accept: 'application/vnd.github+json',
        'Cache-Control': 'no-cache',
      },
      signal: controller.signal,
    })
      .then((response) => {
        if (!response.ok) throw new Error('GitHub repositories are unavailable right now.');
        return response.json();
      })
      .then((data) => {
        setRepos(Array.isArray(data) ? data : []);
        setRepoStatus('ready');
      })
      .catch((error) => {
        if (error.name !== 'AbortError') setRepoStatus('error');
      });

    loadActivity();
    loadRepos();

    const refreshTimer = window.setInterval(() => {
      loadActivity();
      loadRepos();
    }, 60000);

    return () => {
      controller.abort();
      window.clearInterval(refreshTimer);
    };
  }, []);

  return (
    <Section id="github" title="GitHub Timeline">
      <div className="github-panel">
        <div className="github-header">
          <div>
            <p className="eyebrow">Realtime public profile</p>
            <h3>@{username}</h3>
          </div>
          <a href={`https://github.com/${username}`} target="_blank" rel="noreferrer">
            <Github size={18} /> View Profile
          </a>
        </div>

        <div className="contribution-frame">
          <img
            src={`https://ghchart.rshah.org/111827/${username}`}
            alt={`${username} GitHub contribution graph`}
            loading="lazy"
          />
        </div>

        <div className="repo-list" aria-live="polite">
          <div className="repo-list-header">
            <h3>Latest Repositories</h3>
            <span>Updates live from GitHub</span>
          </div>
          {repoStatus === 'loading' && <p className="activity-state">Loading repositories...</p>}
          {repoStatus === 'error' && <p className="activity-state">GitHub repositories could not load right now.</p>}
          {repoStatus === 'ready' && repos.map((repo) => (
            <a className="repo-item" href={repo.html_url} target="_blank" rel="noreferrer" key={repo.id}>
              <span>
                <strong>{repo.name}</strong>
                <small>{repo.description || 'No description added yet.'}</small>
              </span>
              <span className="repo-meta">
                {repo.language && <em>{repo.language}</em>}
                <small>Updated {formatEventDate(repo.updated_at)}</small>
              </span>
            </a>
          ))}
        </div>

        <div className="activity-timeline" aria-live="polite">
          {status === 'loading' && <p className="activity-state">Loading latest GitHub activity...</p>}
          {status === 'error' && <p className="activity-state">GitHub activity could not load right now. The contribution graph above still links to the live account.</p>}
          {status === 'ready' && events.length === 0 && <p className="activity-state">No recent public activity found.</p>}
          {status === 'ready' && events.map((event) => (
            <a className="activity-item" href={`https://github.com/${event.repo?.name ?? username}`} target="_blank" rel="noreferrer" key={event.id}>
              <span className="activity-icon"><GitCommit size={16} /></span>
              <span>
                <strong>{describeGitHubEvent(event)}</strong>
                <small>{formatEventDate(event.created_at)}</small>
              </span>
            </a>
          ))}
        </div>
      </div>
    </Section>
  );
}

function Chatbot() {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([{ sender: 'bot', text: 'Hello! How can I help you today?' }]);
  const [input, setInput] = useState('');
  const [typing, setTyping] = useState(false);
  const listRef = useRef(null);
  const emailAddress = 'venandrewmirasol@gmail.com';

  useEffect(() => {
    listRef.current?.scrollTo({ top: listRef.current.scrollHeight, behavior: 'smooth' });
  }, [messages, typing]);

  const sendMessage = async () => {
    const value = input.trim();
    if (!value) return;
    setMessages((current) => [...current, { sender: 'user', text: value }]);
    setInput('');
    setTyping(true);
    window.setTimeout(() => {
      setTyping(false);
      setMessages((current) => [...current, { sender: 'bot', text: 'Thanks for the message. Connect this widget to a Laravel API route when your Gemini key is ready.' }]);
    }, 700);
  };

  const contactVen = () => {
    const message = input.trim();
    const subject = encodeURIComponent('Portfolio visitor message for Ven Andrew Mirasol');
    const body = encodeURIComponent(
      message
        ? `Hi Ven Andrew Mirasol,\n\n${message}\n\nSent from your portfolio chatbot.`
        : 'Hi Ven Andrew Mirasol,\n\nI visited your portfolio and would like to contact you.\n\nSent from your portfolio chatbot.'
    );

    setMessages((current) => [
      ...current,
      { sender: 'user', text: message || 'Contact Ven Andrew Mirasol' },
      { sender: 'bot', text: 'Opening your email app now so your message can be sent to Ven Andrew Mirasol.' },
    ]);
    setInput('');
    window.location.href = `mailto:${emailAddress}?subject=${subject}&body=${body}`;
  };

  return (
    <>
      <aside className={`chat-container ${open ? 'active' : ''}`} aria-label="AI assistant">
        <header>
          <h2>AI Assistant</h2>
          <button type="button" aria-label="Close chat" onClick={() => setOpen(false)}><X size={22} /></button>
        </header>
        <div className="chat-messages" ref={listRef}>
          {messages.map((message, idx) => (
            <div className={`message ${message.sender}-message`} key={`${message.sender}-${idx}`}>{message.text}</div>
          ))}
          {typing && <div className="typing">Typing...</div>}
        </div>
        <div className="chat-actions">
          <button type="button" onClick={contactVen}>
            <Mail size={16} /> Contact Ven Andrew Mirasol
          </button>
        </div>
        <form className="chat-input" onSubmit={(event) => { event.preventDefault(); sendMessage(); }}>
          <input value={input} onChange={(event) => setInput(event.target.value)} placeholder="Type your message..." />
          <button type="submit" aria-label="Send message"><Send size={16} /></button>
        </form>
      </aside>
      {!open && (
        <button className="chat-toggle" type="button" aria-label="Open chat" onClick={() => setOpen(true)}>
          <Bot size={28} />
        </button>
      )}
    </>
  );
}

function App() {
  const [showTop, setShowTop] = useState(false);

  useEffect(() => {
    const revealSections = () => {
      document.querySelectorAll('.section-hidden').forEach((section) => {
        const rect = section.getBoundingClientRect();
        section.classList.toggle('reveal', rect.top < window.innerHeight - 80 && rect.bottom > 80);
      });
      setShowTop(window.scrollY > 300);
    };
    revealSections();
    window.addEventListener('scroll', revealSections, { passive: true });
    return () => window.removeEventListener('scroll', revealSections);
  }, []);

  return (
    <>
      <Nav />
      <main className="page-shell">
        <header id="home" className="hero">
          <img src={profile} alt="Ven Andrew B. Mirasol" />
          <h1>Hello, I'm Andrew.</h1>
          <TypingText />
          <p>Building mobile & web apps that solve real problems - one project at a time.</p>
          <div className="socials">
            <a href="mailto:venandrewmirasol@gmail.com" aria-label="Email"><Mail size={20} /></a>
            <a href="https://github.com/haruto-web" target="_blank" rel="noreferrer" aria-label="GitHub"><Github size={20} /></a>
            <a href="tel:+639921497659" aria-label="Phone"><Phone size={20} /></a>
          </div>
          <ChevronDown className="down-indicator" size={30} />
        </header>

        <Section id="about" title="About Me">
          <div className="about-grid">
            <img src={profile} alt="Ven Andrew B. Mirasol" />
            <div>
              <p>I'm a BSIT student passionate about turning ideas into functional apps. I specialize in mobile development with Android Studio and Firebase, and I'm expanding into full-stack web development with Laravel, Django, and React.</p>
              <p>I've built projects ranging from recipe-sharing apps to AI-powered job platforms and learning management systems. I'm always looking for the next challenge to grow my skills.</p>
            </div>
          </div>
        </Section>

        <Section id="skills" title="Skills">
          <SkillGroup title="Programming:" items={['Java', 'Python', 'PHP', 'JavaScript', 'SQL']} />
          <SkillGroup title="Frameworks & Technologies:" items={['Firebase', 'Laravel', 'Django', 'React']} />
          <SkillGroup title="Tools:" items={['Android Studio', 'VS Code', 'Git & GitHub', 'MySQL', 'PostgreSQL']} />
          <SkillGroup title="Soft Skills:" items={['Problem-solving', 'Teamwork', 'Communication']} />
        </Section>

        <Section id="projects" title="Projects">
          <h3 className="category-title"><ExternalLink size={18} /> Web</h3>
          <div className="project-grid">
            <ProjectCard title="BrightTrack LMS" description="An LMS with student support monitoring - tracks academic performance, attendance, and wellness to identify at-risk students. Includes AI assistant and ML-based analytics." note="Project in Third-year Student. Built with Django, PostgreSQL, and integrated AI/ML features for student support." tags={['Python', 'Django', 'PostgreSQL', 'ML']} url="https://brighttrack.onrender.com/" />
            <ProjectCard title="JobAI - AI-Powered Job Platform" description="Full-stack job platform connecting employers and job seekers with an AI-powered admin chat assistant. Separate portals for employers, seekers, and admins." note="Project in Second-year Student. Built with Laravel, MySQL, and integrated AI features for admin support." tags={['PHP (Laravel)', 'JavaScript', 'MySQL', 'AI']} url="https://jobai-1-7c66.onrender.com/#" />
            <ProjectCard title="AI-Based Hazard Detection System" badge="Personal Project" description="A Django web app that uses Google Gemini AI to analyze construction site images for safety hazards and automatically notify engineers via email. Features camera capture, image upload, severity rating, and report history." tags={['Python', 'Django', 'Gemini AI']} url="https://ai-based-hazard-detection-system.onrender.com" />
          </div>
          <hr />
          <h3 className="category-title"><Smartphone size={18} /> Mobile</h3>
          <div className="project-grid">
            <ProjectCard title="Study-Sync" description="Android app for students to manage study workflow - task management, analytics dashboard, AR flashcards, and quiz generation from modules." note="Project in Third-year Student. Built with Java, Android Studio, and Firebase for backend services." tags={['Java', 'Android Studio', 'Firebase', 'Firestore']} />
            <ProjectCard title="Recipe Mobile App" description="Mobile app where users post recipes with images and captions. Firebase-backed with user profiles, likes, and image uploads." note="Project in Second-year Student. Built with Java, Android Studio, and Firebase for backend services." tags={['Java', 'Firebase', 'Android Studio']} />
          </div>
        </Section>

        <SnakeGame />

        <GitHubActivity />

        <Section id="education" title="Education">
          <div className="timeline">
            {['Bachelor of Science in Information Technology|Currently Enrolled|Focused on mobile app development, web technologies, and database management. Building real-world projects using Firebase, Laravel, Django, and React.', 'Senior High School|Tanza National Comprehensive High School - Grade 11-12|', 'Junior High School|Tanza National Comprehensive High School - Grade 7-10|', 'Elementary|Felipe Calderon Elementary School - Grade 1-6|'].map((item) => {
              const [title, meta, body] = item.split('|');
              return <div className="timeline-item" key={title}><h3>{title}</h3><p className="muted">{meta}</p>{body && <p>{body}</p>}</div>;
            })}
          </div>
        </Section>

        <Section id="contact" title="Let's Connect">
          <p className="lead">Have a project in mind or just want to say hi? Reach out.</p>
          <div className="contact-grid">
            <a href="mailto:venandrewmirasol@gmail.com"><Mail size={24} /><span><small>Email</small>venandrewmirasol@gmail.com</span></a>
            <a href="https://github.com/haruto-web" target="_blank" rel="noreferrer"><Github size={24} /><span><small>GitHub</small>haruto-web</span></a>
            <a href="https://www.facebook.com/venandrew.mirasol.3" target="_blank" rel="noreferrer"><Facebook size={24} /><span><small>Facebook</small>Ven Andrew B. Mirasol</span></a>
            <a href="tel:+639921497659"><Phone size={24} /><span><small>Phone</small>+63 992 149 7659</span></a>
          </div>
        </Section>

        <footer>&copy; 2025 Ven Andrew B. Mirasol</footer>
      </main>
      <button className={`go-up ${showTop ? 'visible' : ''}`} type="button" aria-label="Go to top" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
        <ArrowUp size={22} />
      </button>
      <Chatbot />
    </>
  );
}

createRoot(document.getElementById('root')).render(<App />);
