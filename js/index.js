/* Navbar-top */

function init() {
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

  /* Search field in downloads section */
  var searchField = document.querySelector('#searchField');
  searchField.onkeyup = function() {
    var searchText = searchField.value.toLowerCase();
    var countries = document.querySelector('#searchField').parentNode.nextElementSibling.children;
    for(var i = 0; i <= countries.length - 1; ++i) {
      var element = countries[i];
      var countryName = element.textContent.toLowerCase();
      if(!( countryName.indexOf(searchText) != -1 )) {
        element.style.display = 'none';
      } else {
        element.style.display = 'list-item';
      }
    }
  }
}
window.onload = init;
