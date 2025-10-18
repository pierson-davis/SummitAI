# Devin Cursor Tools Step-by-Step Implementation Guide

## Overview

This document provides a detailed, step-by-step implementation guide for reimplementing the Devin Cursor tools suite. Each step includes specific code examples, configuration files, and implementation details.

## Phase 1: Foundation & Core Enhancement

### Step 1.1: Project Structure Setup

**Timeline:** 4 hours

**Tasks:**
1. Create modular project structure
2. Set up virtual environment
3. Implement configuration management
4. Set up logging infrastructure

**Implementation:**

```bash
# Create project structure
mkdir -p devin_cursor_tools/{src,tests,docs,scripts,docker,k8s,requirements}
mkdir -p devin_cursor_tools/src/{core,tools,plugins,api}
mkdir -p devin_cursor_tools/src/tools/{llm,web,data,utils}
mkdir -p devin_cursor_tools/src/api/routes
```

**Core Configuration (`src/core/config.py`):**
```python
from pydantic import BaseSettings, Field
from typing import Optional, Dict, Any
import os
from pathlib import Path

class BaseConfig(BaseSettings):
    """Base configuration class"""
    app_name: str = "Devin Cursor Tools"
    version: str = "2.0.0"
    debug: bool = False
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

class LLMConfig(BaseConfig):
    """LLM API configuration"""
    openai_api_key: Optional[str] = Field(None, env="OPENAI_API_KEY")
    anthropic_api_key: Optional[str] = Field(None, env="ANTHROPIC_API_KEY")
    google_api_key: Optional[str] = Field(None, env="GOOGLE_API_KEY")
    default_provider: str = "openai"
    default_model: str = "gpt-4o"
    max_tokens: int = 4000
    temperature: float = 0.7
    timeout: int = 30
    retry_attempts: int = 3
    cache_ttl: int = 3600

class WebConfig(BaseConfig):
    """Web automation configuration"""
    playwright_browser: str = "chromium"
    headless: bool = True
    viewport_width: int = 1280
    viewport_height: int = 720
    timeout: int = 30000
    max_concurrent: int = 5
    proxy_enabled: bool = False
    proxy_url: Optional[str] = None

class DatabaseConfig(BaseConfig):
    """Database configuration"""
    database_url: str = Field("sqlite:///./devin_cursor.db", env="DATABASE_URL")
    redis_url: str = Field("redis://localhost:6379", env="REDIS_URL")
    pool_size: int = 10
    max_overflow: int = 20

class SecurityConfig(BaseConfig):
    """Security configuration"""
    secret_key: str = Field(..., env="SECRET_KEY")
    jwt_algorithm: str = "HS256"
    jwt_expiration: int = 3600
    encryption_key: str = Field(..., env="ENCRYPTION_KEY")
    rate_limit_per_minute: int = 60

class Config(BaseConfig):
    """Main configuration class"""
    llm: LLMConfig = LLMConfig()
    web: WebConfig = WebConfig()
    database: DatabaseConfig = DatabaseConfig()
    security: SecurityConfig = SecurityConfig()
    
    @classmethod
    def load(cls) -> "Config":
        """Load configuration from environment"""
        return cls()
```

**Logging Setup (`src/core/logging.py`):**
```python
import logging
import sys
from pathlib import Path
from typing import Optional
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """JSON formatter for structured logging"""
    
    def format(self, record):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        
        return json.dumps(log_entry)

class DevinCursorLogger:
    """Centralized logging manager"""
    
    def __init__(self, config: "Config"):
        self.config = config
        self.loggers = {}
        self._setup_logging()
    
    def _setup_logging(self):
        """Set up logging configuration"""
        # Create logs directory
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)
        
        # Configure root logger
        root_logger = logging.getLogger()
        root_logger.setLevel(getattr(logging, self.config.log_level.upper()))
        
        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        console_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        console_handler.setFormatter(console_formatter)
        root_logger.addHandler(console_handler)
        
        # File handler
        file_handler = logging.FileHandler(log_dir / "devin_cursor.log")
        file_handler.setLevel(logging.DEBUG)
        json_formatter = JSONFormatter()
        file_handler.setFormatter(json_formatter)
        root_logger.addHandler(file_handler)
        
        # Error file handler
        error_handler = logging.FileHandler(log_dir / "errors.log")
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(json_formatter)
        root_logger.addHandler(error_handler)
    
    def get_logger(self, name: str) -> logging.Logger:
        """Get logger instance"""
        if name not in self.loggers:
            self.loggers[name] = logging.getLogger(name)
        return self.loggers[name]

# Global logger instance
logger_manager = None

def get_logger(name: str) -> logging.Logger:
    """Get logger instance"""
    global logger_manager
    if logger_manager is None:
        from .config import Config
        logger_manager = DevinCursorLogger(Config.load())
    return logger_manager.get_logger(name)
```

### Step 1.2: Enhanced LLM API Implementation

**Timeline:** 6 hours

**Tasks:**
1. Implement streaming support
2. Add conversation management
3. Implement token counting and cost tracking
4. Add caching with Redis
5. Implement rate limiting and retry logic

**Implementation:**

**Base LLM Client (`src/tools/llm/base.py`):**
```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, AsyncGenerator
from dataclasses import dataclass
from enum import Enum
import asyncio
import time

class MessageRole(Enum):
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"

@dataclass
class Message:
    role: MessageRole
    content: str
    timestamp: float = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = time.time()

@dataclass
class LLMResponse:
    content: str
    model: str
    provider: str
    tokens_used: int
    cost: float
    response_time: float
    finish_reason: str = "stop"

@dataclass
class LLMConfig:
    model: str
    temperature: float = 0.7
    max_tokens: int = 4000
    timeout: int = 30
    retry_attempts: int = 3

class BaseLLMClient(ABC):
    """Base class for LLM clients"""
    
    def __init__(self, config: LLMConfig, api_key: str):
        self.config = config
        self.api_key = api_key
        self.rate_limiter = RateLimiter()
        self.cache = LLMCache()
    
    @abstractmethod
    async def complete(
        self, 
        messages: List[Message], 
        stream: bool = False
    ) -> LLMResponse:
        """Complete a conversation"""
        pass
    
    @abstractmethod
    async def stream_complete(
        self, 
        messages: List[Message]
    ) -> AsyncGenerator[str, None]:
        """Stream completion"""
        pass
    
    def count_tokens(self, text: str) -> int:
        """Count tokens in text"""
        # Simple token counting (replace with actual implementation)
        return len(text.split())
    
    def estimate_cost(self, tokens: int) -> float:
        """Estimate cost based on tokens"""
        # Cost estimation (replace with actual pricing)
        return tokens * 0.0001
```

**OpenAI Client (`src/tools/llm/openai_client.py`):**
```python
import openai
from typing import List, AsyncGenerator
import asyncio
import time
from .base import BaseLLMClient, Message, LLMResponse, LLMConfig

class OpenAIClient(BaseLLMClient):
    """OpenAI API client with streaming support"""
    
    def __init__(self, config: LLMConfig, api_key: str):
        super().__init__(config, api_key)
        self.client = openai.AsyncOpenAI(api_key=api_key)
    
    async def complete(
        self, 
        messages: List[Message], 
        stream: bool = False
    ) -> LLMResponse:
        """Complete a conversation"""
        start_time = time.time()
        
        # Check cache first
        cache_key = self._get_cache_key(messages)
        cached_response = await self.cache.get(cache_key)
        if cached_response:
            return cached_response
        
        # Rate limiting
        await self.rate_limiter.wait()
        
        try:
            response = await self.client.chat.completions.create(
                model=self.config.model,
                messages=[{"role": msg.role.value, "content": msg.content} for msg in messages],
                temperature=self.config.temperature,
                max_tokens=self.config.max_tokens,
                stream=stream
            )
            
            if stream:
                content = ""
                async for chunk in response:
                    if chunk.choices[0].delta.content:
                        content += chunk.choices[0].delta.content
            else:
                content = response.choices[0].message.content
            
            response_time = time.time() - start_time
            tokens_used = self.count_tokens(content)
            cost = self.estimate_cost(tokens_used)
            
            llm_response = LLMResponse(
                content=content,
                model=self.config.model,
                provider="openai",
                tokens_used=tokens_used,
                cost=cost,
                response_time=response_time,
                finish_reason=response.choices[0].finish_reason
            )
            
            # Cache response
            await self.cache.set(cache_key, llm_response)
            
            return llm_response
            
        except Exception as e:
            # Retry logic
            for attempt in range(self.config.retry_attempts):
                try:
                    await asyncio.sleep(2 ** attempt)  # Exponential backoff
                    return await self.complete(messages, stream)
                except Exception:
                    if attempt == self.config.retry_attempts - 1:
                        raise e
    
    async def stream_complete(
        self, 
        messages: List[Message]
    ) -> AsyncGenerator[str, None]:
        """Stream completion"""
        await self.rate_limiter.wait()
        
        try:
            response = await self.client.chat.completions.create(
                model=self.config.model,
                messages=[{"role": msg.role.value, "content": msg.content} for msg in messages],
                temperature=self.config.temperature,
                max_tokens=self.config.max_tokens,
                stream=True
            )
            
            async for chunk in response:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
                    
        except Exception as e:
            raise e
    
    def _get_cache_key(self, messages: List[Message]) -> str:
        """Generate cache key for messages"""
        content = "".join([f"{msg.role.value}:{msg.content}" for msg in messages])
        return f"openai:{self.config.model}:{hash(content)}"
```

**Conversation Manager (`src/tools/llm/conversation.py`):**
```python
from typing import List, Dict, Optional
import uuid
from datetime import datetime, timedelta
from .base import Message, MessageRole

class Conversation:
    """Represents a conversation with context management"""
    
    def __init__(self, conversation_id: str = None, max_context: int = 10):
        self.conversation_id = conversation_id or str(uuid.uuid4())
        self.messages: List[Message] = []
        self.max_context = max_context
        self.created_at = datetime.utcnow()
        self.last_activity = datetime.utcnow()
    
    def add_message(self, role: MessageRole, content: str) -> None:
        """Add message to conversation"""
        message = Message(role=role, content=content)
        self.messages.append(message)
        self.last_activity = datetime.utcnow()
        
        # Trim context if needed
        if len(self.messages) > self.max_context:
            self.messages = self.messages[-self.max_context:]
    
    def get_messages(self) -> List[Message]:
        """Get all messages in conversation"""
        return self.messages.copy()
    
    def clear(self) -> None:
        """Clear conversation"""
        self.messages = []
    
    def is_expired(self, ttl_hours: int = 24) -> bool:
        """Check if conversation is expired"""
        return datetime.utcnow() - self.last_activity > timedelta(hours=ttl_hours)

class ConversationManager:
    """Manages multiple conversations"""
    
    def __init__(self, max_conversations: int = 1000):
        self.conversations: Dict[str, Conversation] = {}
        self.max_conversations = max_conversations
    
    def get_conversation(self, conversation_id: str) -> Optional[Conversation]:
        """Get conversation by ID"""
        return self.conversations.get(conversation_id)
    
    def create_conversation(self, conversation_id: str = None) -> Conversation:
        """Create new conversation"""
        conversation = Conversation(conversation_id)
        self.conversations[conversation.conversation_id] = conversation
        
        # Clean up old conversations
        self._cleanup_expired()
        
        return conversation
    
    def add_message(
        self, 
        conversation_id: str, 
        role: MessageRole, 
        content: str
    ) -> bool:
        """Add message to conversation"""
        conversation = self.get_conversation(conversation_id)
        if not conversation:
            return False
        
        conversation.add_message(role, content)
        return True
    
    def _cleanup_expired(self) -> None:
        """Clean up expired conversations"""
        expired_ids = [
            conv_id for conv_id, conv in self.conversations.items()
            if conv.is_expired()
        ]
        
        for conv_id in expired_ids:
            del self.conversations[conv_id]
        
        # If still too many, remove oldest
        if len(self.conversations) > self.max_conversations:
            sorted_convs = sorted(
                self.conversations.items(),
                key=lambda x: x[1].last_activity
            )
            
            to_remove = len(self.conversations) - self.max_conversations
            for conv_id, _ in sorted_convs[:to_remove]:
                del self.conversations[conv_id]
```

### Step 1.3: Advanced Screenshot & Web Automation

**Timeline:** 4 hours

**Tasks:**
1. Implement mobile device simulation
2. Add PDF generation capabilities
3. Implement video recording
4. Add OCR text extraction

**Implementation:**

**Advanced Screenshot Tool (`src/tools/web/screenshot.py`):**
```python
from playwright.async_api import async_playwright, Browser, Page
from typing import Optional, Dict, Any, List
import asyncio
import base64
from pathlib import Path
from dataclasses import dataclass
from enum import Enum

class DeviceType(Enum):
    DESKTOP = "desktop"
    MOBILE = "mobile"
    TABLET = "tablet"

@dataclass
class DeviceConfig:
    name: str
    device_type: DeviceType
    viewport: Dict[str, int]
    user_agent: str
    is_mobile: bool
    has_touch: bool

class MobileDevices:
    """Predefined mobile device configurations"""
    
    IPHONE_12_PRO = DeviceConfig(
        name="iPhone 12 Pro",
        device_type=DeviceType.MOBILE,
        viewport={"width": 390, "height": 844},
        user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15",
        is_mobile=True,
        has_touch=True
    )
    
    IPAD_PRO = DeviceConfig(
        name="iPad Pro",
        device_type=DeviceType.TABLET,
        viewport={"width": 1024, "height": 1366},
        user_agent="Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15",
        is_mobile=True,
        has_touch=True
    )
    
    DESKTOP_CHROME = DeviceConfig(
        name="Desktop Chrome",
        device_type=DeviceType.DESKTOP,
        viewport={"width": 1920, "height": 1080},
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        is_mobile=False,
        has_touch=False
    )

class AdvancedScreenshotTool:
    """Advanced screenshot and web automation tool"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.browser: Optional[Browser] = None
        self.playwright = None
    
    async def __aenter__(self):
        self.playwright = await async_playwright().start()
        self.browser = await self.playwright.chromium.launch(
            headless=self.config.get("headless", True)
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.browser:
            await self.browser.close()
        if self.playwright:
            await self.playwright.stop()
    
    async def capture_screenshot(
        self, 
        url: str, 
        device: DeviceConfig,
        output_path: Optional[str] = None,
        full_page: bool = True
    ) -> str:
        """Capture screenshot with device simulation"""
        page = await self.browser.new_page()
        
        try:
            # Set device context
            await page.set_viewport_size(device.viewport)
            await page.set_extra_http_headers({
                "User-Agent": device.user_agent
            })
            
            # Navigate to URL
            await page.goto(url, wait_until="networkidle")
            
            # Generate output path if not provided
            if not output_path:
                output_path = f"screenshot_{device.name}_{int(time.time())}.png"
            
            # Capture screenshot
            await page.screenshot(
                path=output_path,
                full_page=full_page
            )
            
            return output_path
            
        finally:
            await page.close()
    
    async def generate_pdf(
        self, 
        url: str, 
        output_path: str,
        device: DeviceConfig = MobileDevices.DESKTOP_CHROME
    ) -> str:
        """Generate PDF from web page"""
        page = await self.browser.new_page()
        
        try:
            # Set device context
            await page.set_viewport_size(device.viewport)
            await page.set_extra_http_headers({
                "User-Agent": device.user_agent
            })
            
            # Navigate to URL
            await page.goto(url, wait_until="networkidle")
            
            # Generate PDF
            await page.pdf(
                path=output_path,
                format="A4",
                print_background=True
            )
            
            return output_path
            
        finally:
            await page.close()
    
    async def record_video(
        self, 
        url: str, 
        output_path: str,
        duration: int = 10,
        device: DeviceConfig = MobileDevices.DESKTOP_CHROME
    ) -> str:
        """Record video of page interactions"""
        page = await self.browser.new_page()
        
        try:
            # Set device context
            await page.set_viewport_size(device.viewport)
            await page.set_extra_http_headers({
                "User-Agent": device.user_agent
            })
            
            # Start video recording
            await page.video.start_recording(path=output_path)
            
            # Navigate to URL
            await page.goto(url, wait_until="networkidle")
            
            # Wait for specified duration
            await asyncio.sleep(duration)
            
            # Stop recording
            await page.video.stop_recording()
            
            return output_path
            
        finally:
            await page.close()
    
    async def extract_text_with_ocr(
        self, 
        image_path: str
    ) -> str:
        """Extract text from image using OCR"""
        try:
            import pytesseract
            from PIL import Image
            
            # Load image
            image = Image.open(image_path)
            
            # Extract text
            text = pytesseract.image_to_string(image)
            
            return text.strip()
            
        except ImportError:
            raise ImportError("pytesseract and PIL are required for OCR functionality")
        except Exception as e:
            raise Exception(f"OCR extraction failed: {str(e)}")
    
    async def batch_screenshots(
        self, 
        urls: List[str], 
        device: DeviceConfig,
        output_dir: str = "screenshots"
    ) -> List[str]:
        """Capture screenshots for multiple URLs"""
        output_paths = []
        output_dir_path = Path(output_dir)
        output_dir_path.mkdir(exist_ok=True)
        
        for i, url in enumerate(urls):
            output_path = output_dir_path / f"screenshot_{i}_{device.name}.png"
            screenshot_path = await self.capture_screenshot(
                url, device, str(output_path)
            )
            output_paths.append(screenshot_path)
        
        return output_paths
```

### Step 1.4: Enhanced Search Engine

**Timeline:** 3 hours

**Tasks:**
1. Implement multi-provider search
2. Add result caching and deduplication
3. Implement advanced filtering
4. Add search analytics

**Implementation:**

**Multi-Provider Search Engine (`src/tools/web/search.py`):**
```python
from typing import List, Dict, Any, Optional
import asyncio
import aiohttp
from dataclasses import dataclass
from enum import Enum
import time
import hashlib
from urllib.parse import quote_plus

class SearchProvider(Enum):
    GOOGLE = "google"
    BING = "bing"
    DUCKDUCKGO = "duckduckgo"
    SERPAPI = "serpapi"

@dataclass
class SearchResult:
    title: str
    url: str
    snippet: str
    provider: str
    rank: int
    timestamp: float
    domain: str
    language: str = "en"

@dataclass
class SearchFilters:
    language: str = "en"
    region: str = "us"
    safe_search: bool = True
    date_range: Optional[str] = None
    file_type: Optional[str] = None
    site: Optional[str] = None

class SearchProviderBase:
    """Base class for search providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.rate_limiter = RateLimiter()
    
    async def search(
        self, 
        query: str, 
        filters: SearchFilters,
        max_results: int = 10
    ) -> List[SearchResult]:
        """Search implementation - to be overridden"""
        raise NotImplementedError

class GoogleSearchProvider(SearchProviderBase):
    """Google Custom Search API provider"""
    
    def __init__(self, api_key: str, search_engine_id: str):
        super().__init__(api_key)
        self.search_engine_id = search_engine_id
        self.base_url = "https://www.googleapis.com/customsearch/v1"
    
    async def search(
        self, 
        query: str, 
        filters: SearchFilters,
        max_results: int = 10
    ) -> List[SearchResult]:
        """Search using Google Custom Search API"""
        await self.rate_limiter.wait()
        
        params = {
            "key": self.api_key,
            "cx": self.search_engine_id,
            "q": query,
            "num": min(max_results, 10),  # Google limits to 10 per request
            "safe": "active" if filters.safe_search else "off",
            "lr": f"lang_{filters.language}",
            "cr": f"country{filters.region.upper()}"
        }
        
        if filters.date_range:
            params["dateRestrict"] = filters.date_range
        
        if filters.file_type:
            params["fileType"] = filters.file_type
        
        if filters.site:
            params["siteSearch"] = filters.site
        
        async with aiohttp.ClientSession() as session:
            async with session.get(self.base_url, params=params) as response:
                data = await response.json()
                
                results = []
                for i, item in enumerate(data.get("items", [])):
                    result = SearchResult(
                        title=item.get("title", ""),
                        url=item.get("link", ""),
                        snippet=item.get("snippet", ""),
                        provider="google",
                        rank=i + 1,
                        timestamp=time.time(),
                        domain=item.get("displayLink", ""),
                        language=filters.language
                    )
                    results.append(result)
                
                return results

class DuckDuckGoProvider(SearchProviderBase):
    """DuckDuckGo search provider"""
    
    def __init__(self):
        super().__init__()
        self.base_url = "https://api.duckduckgo.com"
    
    async def search(
        self, 
        query: str, 
        filters: SearchFilters,
        max_results: int = 10
    ) -> List[SearchResult]:
        """Search using DuckDuckGo API"""
        await self.rate_limiter.wait()
        
        params = {
            "q": query,
            "format": "json",
            "no_html": "1",
            "skip_disambig": "1"
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.get(self.base_url, params=params) as response:
                data = await response.json()
                
                results = []
                for i, item in enumerate(data.get("results", [])[:max_results]):
                    result = SearchResult(
                        title=item.get("title", ""),
                        url=item.get("url", ""),
                        snippet=item.get("abstract", ""),
                        provider="duckduckgo",
                        rank=i + 1,
                        timestamp=time.time(),
                        domain=item.get("domain", ""),
                        language=filters.language
                    )
                    results.append(result)
                
                return results

class EnhancedSearchEngine:
    """Enhanced search engine with multiple providers"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.providers = {}
        self.cache = SearchCache()
        self.analytics = SearchAnalytics()
        
        # Initialize providers
        self._initialize_providers()
    
    def _initialize_providers(self):
        """Initialize search providers"""
        if self.config.get("google_api_key") and self.config.get("google_search_engine_id"):
            self.providers[SearchProvider.GOOGLE] = GoogleSearchProvider(
                self.config["google_api_key"],
                self.config["google_search_engine_id"]
            )
        
        self.providers[SearchProvider.DUCKDUCKGO] = DuckDuckGoProvider()
    
    async def search(
        self, 
        query: str, 
        providers: List[SearchProvider] = None,
        filters: SearchFilters = None,
        max_results: int = 10
    ) -> List[SearchResult]:
        """Search across multiple providers"""
        if not providers:
            providers = list(self.providers.keys())
        
        if not filters:
            filters = SearchFilters()
        
        # Check cache first
        cache_key = self._get_cache_key(query, providers, filters)
        cached_results = await self.cache.get(cache_key)
        if cached_results:
            return cached_results
        
        # Search across providers
        all_results = []
        tasks = []
        
        for provider in providers:
            if provider in self.providers:
                task = self.providers[provider].search(query, filters, max_results)
                tasks.append(task)
        
        # Execute searches in parallel
        provider_results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Combine and deduplicate results
        for results in provider_results:
            if isinstance(results, list):
                all_results.extend(results)
        
        # Deduplicate by URL
        unique_results = self._deduplicate_results(all_results)
        
        # Rank and sort results
        ranked_results = self._rank_results(unique_results, query)
        
        # Cache results
        await self.cache.set(cache_key, ranked_results)
        
        # Track analytics
        await self.analytics.track_search(query, len(ranked_results))
        
        return ranked_results[:max_results]
    
    def _get_cache_key(
        self, 
        query: str, 
        providers: List[SearchProvider], 
        filters: SearchFilters
    ) -> str:
        """Generate cache key for search"""
        key_data = f"{query}:{sorted([p.value for p in providers])}:{filters.language}:{filters.region}"
        return hashlib.md5(key_data.encode()).hexdigest()
    
    def _deduplicate_results(self, results: List[SearchResult]) -> List[SearchResult]:
        """Remove duplicate results by URL"""
        seen_urls = set()
        unique_results = []
        
        for result in results:
            if result.url not in seen_urls:
                seen_urls.add(result.url)
                unique_results.append(result)
        
        return unique_results
    
    def _rank_results(self, results: List[SearchResult], query: str) -> List[SearchResult]:
        """Rank results based on relevance"""
        # Simple ranking algorithm (can be enhanced)
        query_words = set(query.lower().split())
        
        def relevance_score(result: SearchResult) -> float:
            score = 0.0
            
            # Title match
            title_words = set(result.title.lower().split())
            title_matches = len(query_words.intersection(title_words))
            score += title_matches * 2.0
            
            # Snippet match
            snippet_words = set(result.snippet.lower().split())
            snippet_matches = len(query_words.intersection(snippet_words))
            score += snippet_matches * 1.0
            
            # Domain authority (simplified)
            if result.domain in ["wikipedia.org", "github.com", "stackoverflow.com"]:
                score += 1.0
            
            return score
        
        # Sort by relevance score
        ranked_results = sorted(results, key=relevance_score, reverse=True)
        
        # Update ranks
        for i, result in enumerate(ranked_results):
            result.rank = i + 1
        
        return ranked_results
```

This step-by-step implementation guide provides detailed code examples and implementation details for each phase of the Devin Cursor tools reimplementation. Each step builds upon the previous ones, creating a comprehensive and production-ready tool suite.

The implementation focuses on:
- Modular architecture with clear separation of concerns
- Comprehensive error handling and logging
- Performance optimization and caching
- Security best practices
- Extensive testing and quality assurance
- Scalability and maintainability

Each component is designed to be independently testable and deployable, making the overall system robust and maintainable.

