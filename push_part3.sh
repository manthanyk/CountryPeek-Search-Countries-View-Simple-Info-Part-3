#!/bin/bash
# Run this script inside your existing CountryPeek project folder
# Usage: bash push_part3.sh

set -e

echo "=== CountryPeek Part 3 — Auto Push Script ==="

# 1. Create branch
git checkout -b part-3/country-detail 2>/dev/null || git checkout part-3/country-detail

# 2. Create hooks folder if missing
mkdir -p src/hooks

# 3. Write useCountry.js
cat > src/hooks/useCountry.js << 'EOF'
import { useState, useEffect } from 'react'

function useCountry(code) {
  const [country, setCountry] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!code) return

    setLoading(true)
    setError(null)

    fetch(`https://restcountries.com/v3.1/alpha/${code}`)
      .then(res => {
        if (!res.ok) throw new Error('Country not found')
        return res.json()
      })
      .then(data => setCountry(data[0]))
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))

  }, [code])

  return { country, loading, error }
}

export default useCountry
EOF

# 4. Write CountryPage.jsx
mkdir -p src/pages
cat > src/pages/CountryPage.jsx << 'EOF'
import { useParams, useNavigate } from 'react-router-dom'
import useCountry from '../hooks/useCountry'
import '../styles/App.css'

function CountryPage() {
  const { code } = useParams()
  const navigate = useNavigate()
  const { country, loading, error } = useCountry(code)

  if (loading) return <p className="page-status">Loading...</p>
  if (error)   return <p className="page-status page-status--error">Error: {error}</p>
  if (!country) return null

  const { name, flags, population, region, subregion, capital, languages, currencies, borders } = country

  const languageList = languages ? Object.values(languages) : []
  const currencyList = currencies ? Object.values(currencies).map(c => c.name) : []

  return (
    <div className="country-page">
      <button className="back-btn" onClick={() => navigate(-1)}>← Back</button>

      <div className="country-page__layout">
        <img className="country-page__flag" src={flags.svg} alt={`Flag of ${name.common}`} />

        <div className="country-page__info">
          <h2 className="country-page__name">{name.common}</h2>
          <p className="country-page__official">{name.official}</p>

          <div className="country-page__details">
            <div>
              <p><strong>Population:</strong> {population.toLocaleString()}</p>
              <p><strong>Region:</strong> {region}</p>
              <p><strong>Sub Region:</strong> {subregion}</p>
              <p><strong>Capital:</strong> {capital?.[0] ?? 'N/A'}</p>
            </div>
            <div>
              <p><strong>Languages:</strong> {languageList.join(', ') || 'N/A'}</p>
              <p><strong>Currencies:</strong> {currencyList.join(', ') || 'N/A'}</p>
            </div>
          </div>

          {borders && borders.length > 0 && (
            <div>
              <strong>Border Countries: </strong>
              {borders.map(b => (
                <span key={b} className="border-badge">{b}</span>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default CountryPage
EOF

# 5. Append CSS to App.css
cat >> src/styles/App.css << 'EOF'

/* =====================
   Country Detail Page
   ===================== */
.country-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.back-btn {
  background: #fff;
  border: 1px solid #ccc;
  padding: 0.4rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  margin-bottom: 2rem;
  box-shadow: 0 1px 4px rgba(0,0,0,0.1);
  font-size: 0.95rem;
}
.back-btn:hover { background: #f0f0f0; }
.country-page__layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: center;
}
@media (max-width: 768px) {
  .country-page__layout { grid-template-columns: 1fr; gap: 2rem; }
}
.country-page__flag {
  width: 100%;
  border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}
.country-page__name { font-size: 1.8rem; font-weight: 700; margin-bottom: 0.25rem; }
.country-page__official { color: #666; margin-bottom: 1.5rem; font-style: italic; }
.country-page__details { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.5rem; }
.country-page__details p { margin: 0.4rem 0; }
.border-badge {
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 0.2rem 0.6rem;
  margin: 0.25rem;
  font-size: 0.85rem;
  background: #fff;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
.page-status { padding: 2rem; color: #666; text-align: center; font-size: 1.1rem; }
.page-status--error { color: #c0392b; }
EOF

echo ""
echo "⚠️  MANUAL STEP — Update src/App.jsx:"
echo "   1. Import CountryPage:  import CountryPage from './pages/CountryPage'"
echo "   2. Change route from:   <Route path=\"/country/:name\" ... />"
echo "      to:                  <Route path=\"/country/:code\" element={<CountryPage />} />"
echo ""

# 6. Commit and push
git add .
git commit -m "feat: add country detail page and useCountry custom hook"
git push origin part-3/country-detail

echo ""
echo "✅ Done! Now open a PR on GitHub: part-3/country-detail → main"
