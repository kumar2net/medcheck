import { useState, useCallback, useReducer } from 'react';

// Reducer for search-related state
const searchReducer = (state, action) => {
  switch (action.type) {
    case 'SET_QUERY':
      return { ...state, query: action.payload };
    case 'SET_CATEGORY':
      return { ...state, category: action.payload };
    case 'SET_RESULTS':
      return { ...state, results: action.payload, isLoading: false };
    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };
    case 'SET_SUGGESTIONS':
      return { ...state, suggestions: action.payload, showSuggestions: action.payload.length > 0 };
    case 'HIDE_SUGGESTIONS':
      return { ...state, showSuggestions: false };
    default:
      return state;
  }
};

// Reducer for UI state
const uiReducer = (state, action) => {
  switch (action.type) {
    case 'SET_SELECTED_DRUG':
      return { ...state, selectedDrug: action.payload };
    case 'SET_SELECTED_DRUG_DETAILS':
      return { ...state, selectedDrugDetails: action.payload, showDetailsModal: true };
    case 'HIDE_DETAILS_MODAL':
      return { ...state, showDetailsModal: false };
    case 'SET_INTERACTION_MODAL':
      return { ...state, showInteractionModal: action.payload };
    case 'SET_INTERACTION_DRUG':
      return { ...state, interactionDrug: action.payload };
    case 'SET_LATEST_INTERACTION_ID':
      return { ...state, latestInteractionId: action.payload };
    default:
      return state;
  }
};

// Custom hook for search state
export const useSearchState = () => {
  const [searchState, searchDispatch] = useReducer(searchReducer, {
    query: '',
    category: 'all',
    results: [],
    isLoading: false,
    suggestions: [],
    showSuggestions: false
  });

  const setQuery = useCallback((query) => {
    searchDispatch({ type: 'SET_QUERY', payload: query });
  }, []);

  const setCategory = useCallback((category) => {
    searchDispatch({ type: 'SET_CATEGORY', payload: category });
  }, []);

  const setResults = useCallback((results) => {
    searchDispatch({ type: 'SET_RESULTS', payload: results });
  }, []);

  const setLoading = useCallback((isLoading) => {
    searchDispatch({ type: 'SET_LOADING', payload: isLoading });
  }, []);

  const setSuggestions = useCallback((suggestions) => {
    searchDispatch({ type: 'SET_SUGGESTIONS', payload: suggestions });
  }, []);

  const hideSuggestions = useCallback(() => {
    searchDispatch({ type: 'HIDE_SUGGESTIONS' });
  }, []);

  return {
    ...searchState,
    setQuery,
    setCategory,
    setResults,
    setLoading,
    setSuggestions,
    hideSuggestions
  };
};

// Custom hook for UI state
export const useUIState = () => {
  const [uiState, uiDispatch] = useReducer(uiReducer, {
    selectedDrug: null,
    selectedDrugDetails: null,
    showDetailsModal: false,
    showInteractionModal: false,
    interactionDrug: '',
    latestInteractionId: null
  });

  const setSelectedDrug = useCallback((drug) => {
    uiDispatch({ type: 'SET_SELECTED_DRUG', payload: drug });
  }, []);

  const setSelectedDrugDetails = useCallback((details) => {
    uiDispatch({ type: 'SET_SELECTED_DRUG_DETAILS', payload: details });
  }, []);

  const hideDetailsModal = useCallback(() => {
    uiDispatch({ type: 'HIDE_DETAILS_MODAL' });
  }, []);

  const setInteractionModal = useCallback((show) => {
    uiDispatch({ type: 'SET_INTERACTION_MODAL', payload: show });
  }, []);

  const setInteractionDrug = useCallback((drug) => {
    uiDispatch({ type: 'SET_INTERACTION_DRUG', payload: drug });
  }, []);

  const setLatestInteractionId = useCallback((id) => {
    uiDispatch({ type: 'SET_LATEST_INTERACTION_ID', payload: id });
  }, []);

  return {
    ...uiState,
    setSelectedDrug,
    setSelectedDrugDetails,
    hideDetailsModal,
    setInteractionModal,
    setInteractionDrug,
    setLatestInteractionId
  };
};

// Custom hook for data state
export const useDataState = () => {
  const [trendingDrugs, setTrendingDrugs] = useState([]);
  const [categoryStats, setCategoryStats] = useState([]);
  const [categories, setCategories] = useState(['all']);
  const [notifications, setNotifications] = useState([]);

  const addNotification = useCallback((notification) => {
    setNotifications(prev => [notification, ...prev]);
  }, []);

  const removeNotification = useCallback((index) => {
    setNotifications(prev => prev.filter((_, i) => i !== index));
  }, []);

  return {
    trendingDrugs,
    setTrendingDrugs,
    categoryStats,
    setCategoryStats,
    categories,
    setCategories,
    notifications,
    addNotification,
    removeNotification
  };
};

// Custom hook for preferences state
export const usePreferencesState = () => {
  const [preferences, setPreferences] = useState({
    price: 'low',
    interactions: [],
    searchHistory: [],
    favoriteDrugs: [],
    priceAlerts: [],
    userPreferences: {
      preferredManufacturers: [],
      preferredCategories: [],
      notifications: true
    }
  });

  const updatePreferences = useCallback((newPreferences) => {
    setPreferences(prev => ({
      ...prev,
      ...newPreferences
    }));
  }, []);

  const addToSearchHistory = useCallback((drugName) => {
    setPreferences(prev => ({
      ...prev,
      searchHistory: [drugName, ...prev.searchHistory.filter(name => name !== drugName)].slice(0, 10)
    }));
  }, []);

  const toggleFavorite = useCallback((drugName) => {
    setPreferences(prev => ({
      ...prev,
      favoriteDrugs: prev.favoriteDrugs.includes(drugName)
        ? prev.favoriteDrugs.filter(name => name !== drugName)
        : [...prev.favoriteDrugs, drugName]
    }));
  }, []);

  const addInteraction = useCallback((interaction) => {
    setPreferences(prev => ({
      ...prev,
      interactions: [...prev.interactions, interaction]
    }));
  }, []);

  return {
    preferences,
    updatePreferences,
    addToSearchHistory,
    toggleFavorite,
    addInteraction
  };
}; 