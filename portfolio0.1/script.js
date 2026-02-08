document.addEventListener('DOMContentLoaded', function () {
  // Burger menu toggle
  const burger = document.querySelector('.burger');
  const navMenu = document.querySelector('nav ul');
  const navLinks = document.querySelectorAll('nav ul li a');

  burger.addEventListener('click', () => {
    burger.classList.toggle('active');
    navMenu.classList.toggle('active');
    document.body.classList.toggle('menu-open');
    burger.setAttribute('aria-expanded', burger.classList.contains('active'));
  });

  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      burger.classList.remove('active');
      navMenu.classList.remove('active');
      document.body.classList.remove('menu-open');
      burger.setAttribute('aria-expanded', 'false');
    });
  });

  const typingText = document.getElementById('typing-text');
  const textArray = [
    "I'm a UX designer.",
    "I'm a Student at TIPmnl.",
    "I'm a traveler."
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
      setTimeout(typeWriter, 2000);
    } else if (isDeleting && charIndex === 0) {
      isDeleting = false;
      textIndex = (textIndex + 1) % textArray.length;
      setTimeout(typeWriter, 500);
    } else {
      setTimeout(typeWriter, isDeleting ? 100 : 150);
    }
  }

  typeWriter();

  // Scroll reveal with throttling
  const sections = document.querySelectorAll('section');
  let ticking = false;

  function revealSections() {
    const scrollTop = window.pageYOffset;

    sections.forEach(section => {
      const offset = section.offsetTop - window.innerHeight + 100;

      if (scrollTop > offset) {
        section.classList.add('reveal');
      }
    });
    
    ticking = false;
  }

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(revealSections);
      ticking = true;
    }
  }

  window.addEventListener('scroll', onScroll);
  revealSections();

  // Go up button
  const goUpBtn = document.getElementById('goUpBtn');
  
  window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
      goUpBtn.classList.add('show');
    } else {
      goUpBtn.classList.remove('show');
    }
  });
  
  goUpBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
});
