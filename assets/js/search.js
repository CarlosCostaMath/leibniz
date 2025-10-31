(function () {
  'use strict';

  const form = document.getElementById('site-search-form');
  if (!form) {
    return;
  }

  const input = form.querySelector('#search-input');
  const resultsContainer = document.getElementById('search-results');
  const feedback = document.getElementById('search-feedback');
  const searchEndpoint = form.getAttribute('data-endpoint') || '/search.json';
  const minQueryLength = 2;
  let index = [];
  let rawPosts = [];
  let isLoading = false;
  let hasLoaded = false;

  const formatter = new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  });

  function removeDiacritics(text) {
    return text
      .toString()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
  }

  function buildIndex(posts) {
    index = posts.map((post) => {
      const { title, excerpt, content, categories = [], tags = [] } = post;
      const searchableParts = [title, excerpt, content]
        .concat(categories)
        .concat(tags)
        .filter(Boolean)
        .join(' ');

      return Object.assign({}, post, {
        searchable: removeDiacritics(searchableParts).toLowerCase()
      });
    });
  }

  function formatDate(value) {
    try {
      return formatter.format(new Date(value));
    } catch (error) {
      return '';
    }
  }

  function createResultItem(post, query) {
    const article = document.createElement('article');
    article.className = 'search-result';

    const header = document.createElement('header');
    header.className = 'search-result__header';

    const titleLink = document.createElement('a');
    titleLink.className = 'search-result__title';
    titleLink.href = post.url;
    titleLink.textContent = post.title;

    const date = document.createElement('time');
    date.className = 'search-result__date';
    date.dateTime = post.date;
    date.textContent = formatDate(post.date);

    header.appendChild(date);
    header.appendChild(titleLink);

    const summary = document.createElement('p');
    summary.className = 'search-result__excerpt';
    summary.innerHTML = emphasiseTerms(post.excerpt || '', query);

    article.appendChild(header);
    article.appendChild(summary);

    return article;
  }

  function emphasiseTerms(text, query) {
    if (!query) {
      return escapeHtml(text);
    }

    const tokens = query
      .trim()
      .split(/\s+/)
      .map((token) => removeDiacritics(token).toLowerCase())
      .filter(Boolean);

    if (!tokens.length) {
      return escapeHtml(text);
    }

    const escapedTokens = tokens.map((token) => token.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
    const regex = new RegExp(`(${escapedTokens.join('|')})`, 'gi');

    return escapeHtml(text).replace(regex, '<mark>$1</mark>');
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function renderResults(results, query) {
    resultsContainer.innerHTML = '';

    if (!results.length) {
      const empty = document.createElement('p');
      empty.className = 'search-results__empty';
      empty.textContent = 'Nenhum conteúdo encontrado para a sua busca.';
      resultsContainer.appendChild(empty);
      updateFeedback(`0 resultados para "${query}".`);
      return;
    }

    const fragment = document.createDocumentFragment();
    results.forEach((result) => {
      fragment.appendChild(createResultItem(result, query));
    });
    resultsContainer.appendChild(fragment);

    updateFeedback(`${results.length} resultado${results.length === 1 ? '' : 's'} encontrado${results.length === 1 ? '' : 's'}.`);
  }

  function updateFeedback(message) {
    if (feedback) {
      feedback.textContent = message;
    }
  }

  function performSearch(query) {
    const normalisedQuery = removeDiacritics(query).toLowerCase().trim();

    if (!normalisedQuery || normalisedQuery.length < minQueryLength) {
      resultsContainer.innerHTML = '';
      updateFeedback('Digite pelo menos duas letras para pesquisar.');
      return;
    }

    const tokens = normalisedQuery.split(/\s+/).filter(Boolean);

    const results = index.filter((item) =>
      tokens.every((token) => item.searchable.includes(token))
    );

    renderResults(results, query.trim());
  }

  function onSubmit(event) {
    event.preventDefault();
    const query = input.value || '';
    if (!hasLoaded) {
      loadIndex().then(() => {
        performSearch(query);
        updateUrl(query);
      });
      return;
    }

    performSearch(query);
    updateUrl(query);
  }

  function updateUrl(query) {
    const url = new URL(window.location.href);
    if (query && query.trim()) {
      url.searchParams.set('q', query.trim());
    } else {
      url.searchParams.delete('q');
    }
    window.history.replaceState({}, document.title, url.toString());
  }

  function loadIndex() {
    if (hasLoaded || isLoading) {
      return Promise.resolve();
    }

    isLoading = true;
    updateFeedback('Carregando conteúdo...');

    return fetch(searchEndpoint)
      .then((response) => {
        if (!response.ok) {
          throw new Error('Não foi possível carregar o índice de busca.');
        }
        return response.json();
      })
      .then((data) => {
        rawPosts = Array.isArray(data) ? data : [];
        buildIndex(rawPosts);
        hasLoaded = true;
        updateFeedback('Índice carregado! Faça sua busca.');
      })
      .catch((error) => {
        console.error(error);
        updateFeedback('Não foi possível carregar a busca no momento. Tente novamente mais tarde.');
      })
      .finally(() => {
        isLoading = false;
      });
  }

  function hydrateFromQueryString() {
    const params = new URLSearchParams(window.location.search);
    const initialQuery = params.get('q');
    if (initialQuery) {
      input.value = initialQuery;
      loadIndex().then(() => performSearch(initialQuery));
    }
  }

  form.addEventListener('submit', onSubmit);

  input.addEventListener('input', function () {
    if (!hasLoaded) {
      return;
    }
    const query = input.value;
    if (!query || query.trim().length < minQueryLength) {
      resultsContainer.innerHTML = '';
      updateFeedback('Digite pelo menos duas letras para pesquisar.');
      updateUrl('');
      return;
    }
    performSearch(query);
  });

  if ('placeholder' in document.createElement('input')) {
    hydrateFromQueryString();
  }

  input.addEventListener('focus', function () {
    if (!hasLoaded && !isLoading) {
      loadIndex();
    }
  });
})();
