'use client'

import { useEffect, useState } from 'react'
import { Search, Receipt } from 'lucide-react'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

interface Sale {
  id: number; order_number: string; customer_name: string
  total: number; payment_method: string; payment_status: string
  cashier_name: string; sale_date: string
}

const METHOD_COLORS: Record<string, string> = {
  cash: 'bg-green-100 text-green-700', mobile: 'bg-blue-100 text-blue-700',
  split: 'bg-purple-100 text-purple-700', debt: 'bg-orange-100 text-orange-700',
}
const STATUS_COLORS: Record<string, string> = {
  paid: 'bg-green-100 text-green-700', partial: 'bg-yellow-100 text-yellow-700',
  pending: 'bg-orange-100 text-orange-700', cancelled: 'bg-red-100 text-red-700',
}

const KES = (n: number) => `KES ${(n || 0).toLocaleString('en-KE', { minimumFractionDigits: 2 })}`

export default function SalesHistoryPage() {
  const [sales, setSales]     = useState<Sale[]>([])
  const [loading, setLoading] = useState(true)
  const [query, setQuery]     = useState('')
  const [filter, setFilter]   = useState('all')

  useEffect(() => {
    api.get<{ success: boolean; sales: Sale[] }>('sales/index.php')
      .then(r => setSales(r.sales || []))
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const filtered = sales.filter(s => {
    const matchQ = !query || s.order_number.toLowerCase().includes(query.toLowerCase()) || s.customer_name?.toLowerCase().includes(query.toLowerCase())
    const matchF = filter === 'all' || s.payment_status === filter
    return matchQ && matchF
  })

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-bold">Sales History</h1>
        <p className="text-muted-foreground text-sm">{sales.length} total records</p>
      </div>

      <div className="flex gap-3 flex-wrap">
        <div className="relative flex-1 min-w-48">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Search by order # or customer…" className="pl-9" value={query} onChange={e => setQuery(e.target.value)} />
        </div>
        <Select value={filter} onValueChange={setFilter}>
          <SelectTrigger className="w-36"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="paid">Paid</SelectItem>
            <SelectItem value="partial">Partial</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {loading ? (
        <div className="space-y-2">{Array.from({ length: 6 }).map((_, i) => <div key={i} className="h-14 rounded-lg bg-muted animate-pulse" />)}</div>
      ) : (
        <div className="rounded-xl border overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="border-b bg-slate-50 dark:bg-slate-800">
              <tr>
                {['Order #','Customer','Method','Status','Total','Cashier','Date'].map(h => (
                  <th key={h} className="text-left px-4 py-3 text-xs font-medium text-muted-foreground uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="text-center py-12 text-muted-foreground">No sales found</td></tr>
              ) : filtered.map(sale => (
                <tr key={sale.id} className="border-b last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 py-3 font-mono font-medium text-indigo-600">{sale.order_number}</td>
                  <td className="px-4 py-3">{sale.customer_name || 'Walk-in'}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium capitalize ${METHOD_COLORS[sale.payment_method] || ''}`}>
                      {sale.payment_method}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium capitalize ${STATUS_COLORS[sale.payment_status] || ''}`}>
                      {sale.payment_status}
                    </span>
                  </td>
                  <td className="px-4 py-3 font-semibold">{KES(sale.total)}</td>
                  <td className="px-4 py-3 text-muted-foreground">{sale.cashier_name}</td>
                  <td className="px-4 py-3 text-muted-foreground text-xs">{new Date(sale.sale_date).toLocaleDateString('en-KE')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
