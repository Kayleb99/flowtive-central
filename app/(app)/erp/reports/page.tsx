'use client'

import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import { Download } from 'lucide-react'
import { Button } from '@/components/ui/button'

const KES = (n: number) => `KES ${(n||0).toLocaleString('en-KE', { minimumFractionDigits: 2 })}`

export default function ReportsPage() {
  const [reports, setReports] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Mock for now or fetch from a dedicated reports endpoint
    setTimeout(() => {
      setReports([
        { date: '2026-09-05', sales: 45, revenue: 84500, profit: 21500, mobile_sales: 60000, cash_sales: 24500 },
        { date: '2026-09-04', sales: 38, revenue: 71200, profit: 18400, mobile_sales: 51000, cash_sales: 20200 },
        { date: '2026-09-03', sales: 52, revenue: 98000, profit: 26000, mobile_sales: 70000, cash_sales: 28000 },
      ])
      setLoading(false)
    }, 500)
  }, [])

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Daily Summaries</h1>
          <p className="text-muted-foreground text-sm">Performance breakdown by day</p>
        </div>
        <Button variant="outline"><Download className="w-4 h-4 mr-2"/> Export CSV</Button>
      </div>

      {loading ? (
        <div className="h-64 bg-muted rounded-xl animate-pulse" />
      ) : (
        <div className="rounded-xl border overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="border-b bg-slate-50 dark:bg-slate-800">
              <tr>{['Date','Orders','Total Revenue','Total Profit','Cash','M-Pesa'].map(h => (
                <th key={h} className="text-left px-4 py-3 text-xs font-medium text-muted-foreground uppercase tracking-wide">{h}</th>
              ))}</tr>
            </thead>
            <tbody>
              {reports.map((r, i) => (
                <tr key={i} className="border-b last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 py-3 font-medium">{new Date(r.date).toLocaleDateString('en-KE')}</td>
                  <td className="px-4 py-3">{r.sales}</td>
                  <td className="px-4 py-3 font-semibold">{KES(r.revenue)}</td>
                  <td className="px-4 py-3 text-green-600 font-medium">{KES(r.profit)}</td>
                  <td className="px-4 py-3">{KES(r.cash_sales)}</td>
                  <td className="px-4 py-3 text-indigo-600">{KES(r.mobile_sales)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
