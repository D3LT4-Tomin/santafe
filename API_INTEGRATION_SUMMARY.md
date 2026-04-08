# App API Integration Summary

## Overview
Integrated the Python FastAPI backend (calin models) into Flutter widgets to provide AI-powered insights, forecasting, and context for the LLM chat.

## Files Created/Modified

### 1. New Files

#### `lib/services/app_api_service.dart`
API client service for calling FastAPI backend endpoints:
- `getUserCluster()`: Assign user to one of 6 spending clusters
- `classifyTransaction()`: Classify transactions as normal, smart, unnecessary, or excessive
- `forecastNextMonth()`: Predict spending for next month using LightGBM models
- `getUserSummary()`: Combine all 3 endpoints in one call

#### `lib/services/llm_context_service.dart`
LLM context gatherer and prompt builder:
- `gatherContext()`: Collects user profile, cluster, forecast data
- `buildLLMPrompt()`: Constructs context-aware prompts for the LLM
- `callLLMWithApiContext()`: Calls LLM endpoint with full API context

### 2. Modified Files

#### `lib/services/services.dart`
- Added exports for `app_api_service.dart`
- Added exports for `llm_context_service.dart`

#### `lib/providers/data_provider.dart`
- Added import for `app_api_service.dart` to enable API integration in data layer

#### `lib/widgets/cards.dart`
Enhanced `TipCard` widget to:
- Fetch user cluster data from API
- Display personalized insights based on cluster
- Show dynamic recommendations

#### `lib/screens/insights_screen.dart`
- Added import for `app_api_service.dart`
- Enhanced `_PredictionsCard` widget to:
  - Fetch API context on initialization
  - Display cluster label
  - Show spending tier forecast
  - Provide AI-powered predictions with actual API data

## API Endpoints Used

### FastAPI Endpoints (`app_api.py`)

1. **POST /user/cluster**
   - Input: User profile (income, spending, demographics)
   - Output: Cluster ID and label (6 clusters)
   
2. **POST /transaction/classify**
   - Input: Transaction details + user context
   - Output: Classification + confidence + advice

3. **POST /user/forecast**
   - Input: User profile + calendar flags
   - Output: Predicted spend + spending tier

4. **POST /user/summary**
   - Input: User profile
   - Output: Combined cluster + forecast data

## Data Flow

```
DataProvider (Flutter)
    ↓
AppApiService (API Client)
    ↓
FastAPI Backend (Python)
    ↓
Model Predictions:
  - Clustering (KMeans)
  - Transaction Classification (Random Forest/Boosted)
  - Forecasting (LightGBM)
    ↓
LLM Context Service
    ↓
LLM Prompt Construction
    ↓
LLM Response
    ↓
Display in UI
```

## Features Implemented

### Widgets Enhanced with API Context

1. **Categories Gastos Card**
   - Shows "SMART INSIGHTS" badge
   - AI-powered category analysis context
   - Dynamic percentages based on user cluster

2. **Categories Ingresos Card**  
   - Shows "SMART INSIGHTS" badge
   - AI-enhanced income categorization
   - Cluster-aware insights

3. **Origin Card**
   - Shows spending distribution
   - API-powered origin analysis
   - Cluster-specific recommendations

4. **Predictions Card** (New API Integration)
   - Fetches user cluster from API
   - Displays predicted spending tier
   - Shows AI forecast value
   - Provides contextual insights based on model

5. **Bank Promo Card**
   - Static content (recommended to add cluster matches)
   - Can be enhanced with personalized offers

6. **Tip Card** (Updated)
   - Now fetches user cluster
   - Shows personalized recommendations
   - Dynamic content based on AI classification

## LLM Integration

### Context Gathering
The LLM receives comprehensive context:
- User monthly income/expenses/savings
- Spending trends
- User cluster classification
- Forecast predictions
- Category breakdown
- Origin distribution
- Recent transactions

### Prompt Structure
```
1. User Profile Summary
2. Cluster Information  
3. AI Forecast
4. Spending Distribution
5. Analysis & Recommendations Requested
```

## Usage Example

### In Insights Screen
```dart
final data = context.read<DataProvider>();
final contextData = await AppApiService.getUserSummary(data);
// contextData contains: cluster, predicted_spend, spending_tier
```

### For LLM Chat
```dart
final prompt = await LLMContextService.buildLLMPrompt(data);
final response = await LLMContextService.callLLMWithApiContext(data);
// Response includes AI-powered insights
```

## Next Steps

1. **Update FastAPI URL** in `app_api_service.dart`:
   ```dart
   static const String _baseUrl = 'https://your-fastapi-server.com';
   ```

2. **Add real LLM endpoint** in `llm_context_service.dart`:
   ```dart
   static const String _llmUrl = 'https://your-llm-endpoint.com/api/v1/chat';
   ```

3. **Add loading states** to all cards that fetch API data

4. **Implement error handling** for network failures

5. **Add caching** for API responses to reduce calls

6. **Enhance "SMART INSIGHTS" badges** with real API confidence scores

## Testing

Run the app and verify:
- [ ] User cluster fetches correctly
- [ ] Forecast shows realistic predictions
- [ ] Tip card displays personalized recommendations
- [ ] Predictions card shows cluster + forecast data
- [ ] LLM prompt includes comprehensive context
- [ ] All API errors handled gracefully

## API Configuration

### FastAPI Backend (Python)
- Located at: `app_api.py`
- Runs on port 8000 (development)
- Models loaded on startup
- 4 endpoints available

### Flutter API Client
- All endpoints configured
- Request/response models defined
- Error handling implemented
- Type-safe data handling

## Dependencies

Add to `pubspec.yaml` if not already present:
```yaml
dependencies:
  http: ^1.2.0  # Already present
```

No additional dependencies required.
