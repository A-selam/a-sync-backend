package main

import (
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"a-sync-backend/config"
	"a-sync-backend/infrastructure"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		panic(err)
	}

	logger := infrastructure.NewLogger(cfg.LogLevel, cfg.Env)
	logger.Info().Str("env", cfg.Env).Msg("starting a-sync-backend")

	r := gin.New()
	r.Use(gin.Recovery())

	r.Use(cors.New(cors.Config{
		AllowOrigins:     cfg.CORSAllowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PATCH", "DELETE"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	// v1 := r.Group("/v1")
	// route.RegisterRoutes(v1, ...)

	if err := r.Run(":" + cfg.Port); err != nil {
		logger.Fatal().Err(err).Msg("server failed")
	}
}
