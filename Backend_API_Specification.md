# Backend API Specification for Tauihi Basketball App

## Overview
This document outlines the backend API endpoints needed to support the Tauihi Basketball iOS app. The backend will act as middleware between the iOS app and the Genius Sports API, providing caching and quota management.

## Base URL
```
https://your-backend-api.com/api
```

## Authentication
All endpoints require API key authentication via header:
```
Authorization: Bearer YOUR_API_KEY
```

## Response Format
All responses follow this structure:
```json
{
  "success": true,
  "data": {...},
  "error": null,
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

## Endpoints

### 1. Teams
**GET** `/teams?leagueId={leagueId}`

Returns all teams in a specific league.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Northern Kāhu",
      "externalId": "NK001",
      "leagueId": 1,
      "clubId": 1,
      "logo": "https://example.com/logo.png",
      "venueId": 1
    }
  ],
  "error": null,
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

### 2. Games
**GET** `/games?competitionId={competitionId}`

Returns all games in a competition.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "competitionId": 1,
      "externalId": "G001",
      "scheduledTime": "2024-01-01T19:00:00Z",
      "startTime": "2024-01-01T19:05:00Z",
      "endTime": null,
      "status": "inprogress",
      "venueId": 1,
      "homeTeamId": 1,
      "awayTeamId": 2,
      "homeScore": 85,
      "awayScore": 78,
      "periods": [
        {
          "periodNumber": 1,
          "homeScore": 25,
          "awayScore": 20,
          "status": "ended"
        }
      ]
    }
  ],
  "error": null,
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

### 3. Live Games
**GET** `/games/live?competitionId={competitionId}`

Returns only live games in a competition.

### 4. Standings
**GET** `/standings?competitionId={competitionId}`

Returns current standings for a competition.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "competitionId": 1,
      "teamId": 1,
      "rank": 1,
      "wins": 8,
      "losses": 2,
      "draws": 0,
      "pointsFor": 850,
      "pointsAgainst": 720,
      "percentage": 0.800
    }
  ],
  "error": null,
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

### 5. Players
**GET** `/players?teamId={teamId}`

Returns all players in a team.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "firstName": "Sarah",
      "lastName": "Johnson",
      "externalId": "P001",
      "photo": "https://example.com/photo.jpg",
      "jerseyNumber": "10",
      "position": "Guard"
    }
  ],
  "error": null,
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

### 6. Team Statistics
**GET** `/statistics/team?teamId={teamId}&competitionId={competitionId}`

Returns team statistics for a competition.

### 7. Player Statistics
**GET** `/statistics/player?playerId={playerId}&competitionId={competitionId}`

Returns player statistics for a competition.

### 8. Match Details
**GET** `/games/{matchId}`

Returns detailed information about a specific match.

### 9. Match Statistics
**GET** `/games/{matchId}/statistics`

Returns statistics for a specific match.

### 10. Match Actions
**GET** `/games/{matchId}/actions`

Returns play-by-play actions for a specific match.

## Caching Strategy

### Cache Durations
- **News**: 30 minutes
- **Standings**: 10 minutes
- **Games**: 5 minutes
- **Live Data**: 30 seconds
- **Team/Player Data**: 1 hour

### Cache Headers
Include cache information in response headers:
```
X-Cache-Status: HIT
X-Cache-Expires: 2024-01-01T00:05:00Z
```

## Error Handling

### Error Response Format
```json
{
  "success": false,
  "data": null,
  "error": "Error message",
  "timestamp": "2024-01-01T00:00:00Z",
  "cached": false
}
```

### HTTP Status Codes
- `200`: Success
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `429`: Rate Limited
- `500`: Internal Server Error

## Rate Limiting
- Implement rate limiting per API key
- Return `429` status code when limit exceeded
- Include retry-after header

## Genius Sports API Integration

### Configuration
- **API Key**: `4b1a43036f40c7762a694255636eab03`
- **Base URL**: `https://api.wh.geniussports.com/v1/basketball`
- **Quota**: 250,000 API calls

### Headers
```
x-api-key: 4b1a43036f40c7762a694255636eab03
Content-Type: application/json
Accept: application/json
```

### Response Format
Genius Sports returns data in this format:
```json
{
  "meta": {
    "version": "1.0",
    "code": 200,
    "status": "success",
    "request": "/basketball/teams",
    "time": 1640995200,
    "count": 10,
    "limit": 10
  },
  "data": [...]
}
```

## Implementation Notes

1. **Caching**: Implement Redis or similar for fast caching
2. **Database**: Store frequently accessed data in PostgreSQL/MySQL
3. **Background Jobs**: Use Celery or similar for data refresh
4. **Monitoring**: Track API usage and cache hit rates
5. **Logging**: Log all API calls and errors
6. **Security**: Validate all input parameters
7. **Performance**: Use connection pooling and async processing

## Development Setup

### Environment Variables
```
GENIUS_SPORTS_API_KEY=4b1a43036f40c7762a694255636eab03
GENIUS_SPORTS_BASE_URL=https://api.wh.geniussports.com/v1/basketball
REDIS_URL=redis://localhost:6379
DATABASE_URL=postgresql://user:pass@localhost/tauihi
```

### Testing
- Use Genius Sports test environment for development
- Implement unit tests for all endpoints
- Use mock data for development when needed 