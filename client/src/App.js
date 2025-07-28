import React, { useState } from 'react';
import FamilyDashboard from './components/FamilyDashboard';
import InteractionChecker from './components/InteractionChecker';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="App">
      <nav className="app-navigation">
        <div className="nav-container">
          <div className="nav-brand">
            <h1>💊 DrugReco</h1>
          </div>
          <div className="nav-tabs">
            <button 
              className={`nav-tab ${activeTab === 'dashboard' ? 'active' : ''}`}
              onClick={() => setActiveTab('dashboard')}
            >
              👨‍👩‍👧‍👦 Family Dashboard
            </button>
            <button 
              className={`nav-tab ${activeTab === 'interactions' ? 'active' : ''}`}
              onClick={() => setActiveTab('interactions')}
            >
              🔍 Interaction Checker
            </button>
          </div>
        </div>
      </nav>

                   <main className="app-main">
               {activeTab === 'dashboard' && <FamilyDashboard />}
               {activeTab === 'interactions' && <InteractionChecker />}
             </main>
             
             <footer className="app-disclaimer">
               <div className="disclaimer-content">
                 <p>
                   <strong>⚠️ IMPORTANT DISCLAIMER:</strong> This application is for informational purposes only. 
                   Always consult a qualified doctor or medical professional before making any decisions about medications, 
                   drug interactions, or treatment plans. The information provided here should not replace professional medical advice.
                 </p>
               </div>
             </footer>
    </div>
  );
}

export default App; 