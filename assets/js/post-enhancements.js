(function () {
  document.addEventListener('DOMContentLoaded', function () {
    const root = document.documentElement;

    const fontIncrease = document.getElementById('fontIncrease');
    const fontDecrease = document.getElementById('fontDecrease');
    const mobileFontIncrease = document.getElementById('mobileFontIncrease');
    const mobileFontDecrease = document.getElementById('mobileFontDecrease');
    const fontControls = [fontIncrease, fontDecrease, mobileFontIncrease, mobileFontDecrease].filter(Boolean);

    if (fontControls.length > 0) {
      let fontSize = parseInt(localStorage.getItem('fontSize'), 10);
      if (Number.isNaN(fontSize) || fontSize <= 0) {
        fontSize = 100;
      }
      root.style.fontSize = fontSize + '%';

      const increase = function () {
        if (fontSize < 130) {
          fontSize += 10;
          root.style.fontSize = fontSize + '%';
          localStorage.setItem('fontSize', fontSize);
        }
      };

      const decrease = function () {
        if (fontSize > 80) {
          fontSize -= 10;
          root.style.fontSize = fontSize + '%';
          localStorage.setItem('fontSize', fontSize);
        }
      };

      fontIncrease?.addEventListener('click', increase);
      mobileFontIncrease?.addEventListener('click', increase);
      fontDecrease?.addEventListener('click', decrease);
      mobileFontDecrease?.addEventListener('click', decrease);
    }

    const navBar = document.querySelector('.post-nav-bar');
    if (navBar) {
      window.addEventListener('scroll', function () {
        const scrollY = window.pageYOffset || document.documentElement.scrollTop;
        navBar.style.opacity = scrollY > 200 ? '1' : '0';
        navBar.style.transform = scrollY > 200 ? 'translateY(0)' : 'translateY(-100%)';
      });
    }

    const progressBar = document.getElementById('readingProgress');
    if (progressBar) {
      window.addEventListener('scroll', function () {
        const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
        const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const progress = height > 0 ? (winScroll / height) * 100 : 0;
        progressBar.style.width = progress + '%';
      });
    }

    const mobileNavMenu = document.getElementById('mobileNavMenu');
    const tocDropdown = document.getElementById('tocDropdown');
    const tocList = document.getElementById('tocList');
    const tocToggle = document.getElementById('tocToggle');
    const mobileTocToggle = document.getElementById('mobileTocToggle');

    if (tocDropdown && tocList) {
      const toggleTOC = function () {
        tocDropdown.classList.toggle('active');
        mobileNavMenu?.classList.remove('active');
      };

      tocToggle?.addEventListener('click', toggleTOC);
      mobileTocToggle?.addEventListener('click', toggleTOC);

      const headings = document.querySelectorAll('.post-content h2, .post-content h3');
      const tocLinks = [];

      headings.forEach(function (heading, index) {
        if (!heading.id) {
          heading.id = 'heading-' + index;
        }
        const li = document.createElement('li');
        const link = document.createElement('a');
        link.href = '#' + heading.id;
        link.textContent = heading.textContent || '';
        link.dataset.targetId = heading.id;
        link.addEventListener('click', function (event) {
          event.preventDefault();
          heading.scrollIntoView({ behavior: 'smooth' });
          tocDropdown.classList.remove('active');
          mobileNavMenu?.classList.remove('active');
        });
        li.appendChild(link);
        tocList.appendChild(li);
        tocLinks.push(link);
      });

      if (tocLinks.length > 0 && 'IntersectionObserver' in window) {
        const observer = new IntersectionObserver(function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              tocLinks.forEach(function (link) {
                link.classList.remove('active');
              });
              const activeLink = tocList.querySelector('a[data-target-id="' + entry.target.id + '"]');
              activeLink?.classList.add('active');
            }
          });
        }, { threshold: 0.5, rootMargin: '-20% 0px -35% 0px' });

        headings.forEach(function (heading) {
          observer.observe(heading);
        });
      }
    }

    const shareButton = document.getElementById('shareButton');
    const mobileShareButton = document.getElementById('mobileShareButton');
    const shareButtons = [shareButton, mobileShareButton].filter(Boolean);

    if (shareButtons.length > 0) {
      const shareText = shareButton?.dataset.shareText || mobileShareButton?.dataset.shareText || '';
      const handleShare = function () {
        const payload = {
          title: document.title,
          text: shareText || undefined,
          url: window.location.href
        };

        if (navigator.share) {
          navigator.share(payload).catch(function () { /* no-op */ });
        } else if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(window.location.href).then(function () {
            alert('Link copiado!');
          }).catch(function () { /* no-op */ });
        }
      };

      shareButtons.forEach(function (button) {
        button.addEventListener('click', handleShare);
      });
    }

    const postContent = document.querySelector('.post-content');
    if (postContent) {
      const autoAnimateSelectors = [
        ':scope > p',
        ':scope > ul',
        ':scope > ol',
        ':scope > blockquote',
        ':scope > pre',
        ':scope > table'
      ];

      autoAnimateSelectors.forEach(function (selector) {
        postContent.querySelectorAll(selector).forEach(function (element) {
          if (!element.dataset.animate) {
            element.setAttribute('data-animate', 'fade-up');
          }
        });
      });

      postContent.querySelectorAll(':scope > h2, :scope > h3').forEach(function (heading) {
        if (!heading.dataset.animate) {
          heading.setAttribute('data-animate', 'fade-up');
          heading.dataset.animateDelay = '80';
        }
      });

      postContent.querySelectorAll('.timeline-item.post-box').forEach(function (item, index) {
        if (!item.dataset.animateDelay) {
          item.dataset.animateDelay = index * 120 + 'ms';
        }
      });
    }

    const animatedElements = document.querySelectorAll('[data-animate]');
    const motionQuery = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };

    const revealImmediately = function () {
      animatedElements.forEach(function (element) {
        element.classList.add('is-visible');
      });
    };

    if (!('IntersectionObserver' in window) || motionQuery.matches) {
      revealImmediately();
    } else {
      const animateObserver = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            const target = entry.target;
            target.classList.add('is-visible');
            animateObserver.unobserve(target);
          }
        });
      }, { threshold: 0.2, rootMargin: '0px 0px -10% 0px' });

      animatedElements.forEach(function (element, index) {
        const delayAttr = element.dataset.animateDelay ? element.dataset.animateDelay.toString().trim() : '';
        if (delayAttr) {
          const hasUnit = /(ms|s)$/i.test(delayAttr);
          element.style.setProperty('--animate-delay', hasUnit ? delayAttr : delayAttr + 'ms');
        } else if (!element.style.getPropertyValue('--animate-delay')) {
          const computedDelay = Math.min(index * 70, 420);
          element.style.setProperty('--animate-delay', computedDelay + 'ms');
        }
        animateObserver.observe(element);
      });

      const handleMotionChange = function (event) {
        if (event.matches) {
          animatedElements.forEach(function (element) {
            element.classList.add('is-visible');
          });
        }
      };

      if (motionQuery.addEventListener) {
        motionQuery.addEventListener('change', handleMotionChange);
      } else if (motionQuery.addListener) {
        motionQuery.addListener(handleMotionChange);
      }
    }

    const lightbox = document.getElementById('lightbox');
    const lightboxImage = document.getElementById('lightboxImage');
    if (lightbox && lightboxImage) {
      document.querySelectorAll('.post-content img').forEach(function (img) {
        img.addEventListener('click', function () {
          lightbox.classList.add('active');
          lightboxImage.src = img.src;
          lightboxImage.alt = img.alt || '';
        });
      });

      document.getElementById('lightboxClose')?.addEventListener('click', function (event) {
        event.stopPropagation();
        lightbox.classList.remove('active');
      });

      lightbox.addEventListener('click', function () {
        lightbox.classList.remove('active');
      });
    }

    const backToTop = document.getElementById('backToTop');
    if (backToTop) {
      window.addEventListener('scroll', function () {
        if (window.pageYOffset > 300) {
          backToTop.classList.add('visible');
        } else {
          backToTop.classList.remove('visible');
        }
      });

      backToTop.addEventListener('click', function (event) {
        event.preventDefault();
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    mobileMenuToggle?.addEventListener('click', function (event) {
      event.stopPropagation();
      mobileNavMenu?.classList.toggle('active');
      tocDropdown?.classList.remove('active');
    });

    document.addEventListener('click', function (event) {
      if (mobileNavMenu && !mobileMenuToggle?.contains(event.target) && !mobileNavMenu.contains(event.target)) {
        mobileNavMenu.classList.remove('active');
      }
    });

    document.addEventListener('click', function (event) {
      if (tocDropdown && !tocToggle?.contains(event.target) && !mobileTocToggle?.contains(event.target) && !tocDropdown.contains(event.target)) {
        tocDropdown.classList.remove('active');
      }
    });
  });
})();
