'use client'

import { motion, AnimatePresence } from 'framer-motion'
import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'

const fadeIn = {
  hidden: { opacity: 0, y: 20, filter: "blur(10px)" },
  visible: {
    opacity: 1,
    y: 0,
    filter: "blur(0px)",
    transition: { 
      duration: 1,
      ease: [0.25, 0.1, 0, 1]
    }
  },
  exit: {
    opacity: 0,
    y: -20,
    filter: "blur(10px)",
    transition: { 
      duration: 0.8,
      ease: [0.25, 0.1, 0, 1]
    }
  }
}

const headerVariant = {
  hidden: { opacity: 0, y: -20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { 
      duration: 0.8,
      delay: 0.2
    }
  }
}

export default function HomePage() {
  const [showOriginal, setShowOriginal] = useState(true)

  useEffect(() => {
    const timer = setTimeout(() => {
      setShowOriginal(false)
    }, 3000) // Increased duration for better readability
    return () => clearTimeout(timer)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-b from-background via-background/95 to-muted relative">
      {/* Header with Login */}
      <motion.div
        variants={headerVariant}
        initial="hidden"
        animate="visible"
        className="absolute top-0 right-0 p-6"
      >
        <Button
          variant="ghost"
          className="text-sm font-medium hover:bg-background/50"
          asChild
        >
          <a href="/api/auth/login" className="text-muted-foreground hover:text-foreground transition-colors">
            Sign In →
          </a>
        </Button>
      </motion.div>

      {/* Main Content */}
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <AnimatePresence mode="wait">
            {showOriginal ? (
              <motion.div
                key="original"
                initial="hidden"
                animate="visible"
                exit="exit"
                variants={fadeIn}
                className="text-4xl sm:text-7xl text-foreground/90 tracking-wider"
              >
                <span>ἀμείνονες εἴδη</span>
              </motion.div>
            ) : (
              <motion.div
                key="final"
                initial="hidden"
                animate="visible"
                exit="exit"
                variants={fadeIn}
                className="space-y-6"
              >
                <h1 className="text-4xl sm:text-6xl font-light text-foreground/90">
                  Archiverse
                </h1>
                <p className="text-lg text-muted-foreground max-w-[600px] mx-auto px-4">
                  Secure your digital realm with enterprise-grade authentication
                </p>
                <div className="pt-4">
                  <Button asChild size="lg">
                    <a href="/api/auth/login">
                      Get Started
                    </a>
                  </Button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  )
}
