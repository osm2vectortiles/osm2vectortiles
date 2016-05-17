document.addEventListener("DOMContentLoaded", function() {
  /* Navbar Hamburger */
  var navsideBtn = document.querySelector('.navside-btn');
  if (navsideBtn) {
    navsideBtn.addEventListener(
            'click', openMenu
            );
    var bg = document.createElement('div');
    bg.setAttribute('class', 'navside-bg');
    bg.addEventListener('click', openMenu);
    document.body.appendChild(bg);
  }

  function openMenu() {
    var menu = document.querySelector('.navside').classList;
    if (menu.contains('open')) {
      menu.remove('open');
      bg.classList.remove('open');
    } else {
      menu.add('open');
      bg.classList.add('open');
    }
  }

  /* Navbar-top */
  var navMobileBtn = document.querySelector('#nav-mobile-btn');
  if (navMobileBtn) {
    navMobileBtn.onclick = function() {
      var navMobileNav = document.getElementById('nav-mobile-nav');
      var navMobileBtn = document.getElementById('nav-mobile-btn');
      if (navMobileNav.className === 'active') {
        navMobileNav.className = '';
        navMobileBtn.className = '';
      } else {
        navMobileNav.className = 'active';
        navMobileBtn.className = 'active';
      }
    };
  }
});
