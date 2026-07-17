package config

import (
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Port               string
	Env                string
	DatabaseURL        string
	RedisURL           string
	APIKeyHashSecret   string
	CORSAllowedOrigins []string
	LogLevel           string
}

// Load reads configuration from environment variables (and a local .env file
// in development). Env vars always win over .env file values.
func Load() (*Config, error) {
	v := viper.New()
	v.SetConfigFile(".env")
	v.SetConfigType("env")
	v.AutomaticEnv()

	// It's fine if .env doesn't exist (e.g. in production / Render) — env vars
	// are already injected directly there.
	_ = v.ReadInConfig()

	v.SetDefault("PORT", "8080")
	v.SetDefault("ENV", "development")
	v.SetDefault("LOG_LEVEL", "debug")
	v.SetDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000")

	cfg := &Config{
		Port:             v.GetString("PORT"),
		Env:              v.GetString("ENV"),
		DatabaseURL:      v.GetString("DATABASE_URL"),
		RedisURL:         v.GetString("REDIS_URL"),
		APIKeyHashSecret: v.GetString("API_KEY_HASH_SECRET"),
		LogLevel:         v.GetString("LOG_LEVEL"),
	}

	origins := v.GetString("CORS_ALLOWED_ORIGINS")
	for _, o := range strings.Split(origins, ",") {
		if o = strings.TrimSpace(o); o != "" {
			cfg.CORSAllowedOrigins = append(cfg.CORSAllowedOrigins, o)
		}
	}

	return cfg, nil
}

func Broken() string { return "bad" }
