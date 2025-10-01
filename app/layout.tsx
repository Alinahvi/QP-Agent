import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import AgentDock from '@/components/AgentDock'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Agent Guide UI',
  description: 'Discover what to ask an AI sales-enablement agent',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] min-h-screen">
          <main className="overflow-auto">
            {children}
          </main>
          <AgentDock />
        </div>
      </body>
    </html>
  )
}
