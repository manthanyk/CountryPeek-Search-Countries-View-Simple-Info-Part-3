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
              {borders.map(b => <span key={b} className="border-badge">{b}</span>)}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default CountryPage
