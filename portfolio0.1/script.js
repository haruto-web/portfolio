document.addEventListener('DOMContentLoaded', function () {
  const burger = document.querySelector('.burger');
  const navMenu = document.querySelector('nav ul');
  const navLinks = document.querySelectorAll('nav ul li a');

  burger.addEventListener('click', () => {
    navMenu.classList.toggle('active');
    document.body.classList.toggle('menu-open');
    burger.querySelector('i').classList.toggle('rotate-90');
    burger.setAttribute('aria-expanded', navMenu.classList.contains('active'));
  });

  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      navMenu.classList.remove('active');
      document.body.classList.remove('menu-open');
      burger.querySelector('i').classList.remove('rotate-90');
      burger.setAttribute('aria-expanded', 'false');
    });
  });

  const typingText = document.getElementById('typing-text');
  const textArray = [
    "UX Designer|BSIT Student",
    "Mobile & Web Developer",
    "Firebase \u2022 Laravel \u2022 Django \u2022 React"
  ];

  let textIndex = 0;
  let charIndex = 0;
  let isDeleting = false;

  function typeWriter() {
    if (!typingText) return;
    const currentText = textArray[textIndex];

    if (isDeleting) {
      typingText.textContent = currentText.substring(0, charIndex--);
    } else {
      typingText.textContent = currentText.substring(0, charIndex++);
    }

    if (!isDeleting && charIndex === currentText.length) {
      isDeleting = true;
      setTimeout(typeWriter, 1500);
    } else if (isDeleting && charIndex === 0) {
      isDeleting = false;
      textIndex = (textIndex + 1) % textArray.length;
      setTimeout(typeWriter, 300);
    } else {
      setTimeout(typeWriter, isDeleting ? 40 : 80);
    }
  }

  typeWriter();

  // Scroll reveal
  const sections = document.querySelectorAll('.section-hidden');
  let ticking = false;

  function revealSections() {
    sections.forEach(section => {
      if (window.pageYOffset > section.offsetTop - window.innerHeight + 100) {
        section.classList.add('reveal');
      }
    });
    ticking = false;
  }

  window.addEventListener('scroll', () => {
    if (!ticking) { window.requestAnimationFrame(revealSections); ticking = true; }
  });
  revealSections();

  // Go up button
  const goUpBtn = document.getElementById('goUpBtn');

  window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
      goUpBtn.classList.add('opacity-100', 'visible');
      goUpBtn.classList.remove('opacity-0', 'invisible');
    } else {
      goUpBtn.classList.remove('opacity-100', 'visible');
      goUpBtn.classList.add('opacity-0', 'invisible');
    }
  });

  goUpBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
});
