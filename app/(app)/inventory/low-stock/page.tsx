'use client'

import { useEffect, useState } from 'react'
import { AlertTriangle, TrendingDown } from 'lucide-react'
import { api } from '@/lib/api'

interface LowStockProduct { id: number; name: string; sku: string; current_stock: number; minimum_stock: number; selling_price: number; category_name: string }

const KES = (n: number) => `KES ${(n||0).toLocaleString('en-KE', { minimumFractionDigits: 2 })}`

export default function LowStockPage() {
  const [items, setItems]   = useState<LowStockProduct[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<{ success: boolean; products: LowStockProduct[] }>('products/index.php?low_stock=1')
      .then(r => {
        const all = r.products || []
        setItems(all.filter(p => p.current_stock <= p.minimum_stock))
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
          <AlertTriangle className="w-5 h-5 text-red-500" />
        </div>
        <div>
          <h1 className="text-2xl font-bold">Low Stock Alert</h1>
          <p className="text-muted-foreground text-sm">{items.length} items need restocking</p>
        </div>
      </div>

      {loading ? (
        <div className="space-y-2">{Array.from({length:5}).map((_,i) => <div key={i} className="h-14 rounded-lg bg-muted animate-pulse" />)}</div>
      ) : items.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <TrendingDown className="w-10 h-10 mx-auto mb-3 opacity-30" />
          <p>All stock levels are healthy!</p>
        </div>
      ) : (
        <div className="rounded-xl border overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="border-b bg-slate-50 dark:bg-slate-800">
              <tr>{['Product','SKU','Category','Current Stock','Min Stock','Price'].map(h => (
                <th key={h} className="text-left px-4 py-3 text-xs font-medium text-muted-foreground uppercase tracking-wide">{h}</th>
              ))}</tr>
            </thead>
            <tbody>
              {items.map(p => (
                <tr key={p.id} className="border-b last:border-0 bg-red-50/50 dark:bg-red-900/10">
                  <td className="px-4 py-3 font-medium">{p.name}</td>
                  <td className="px-4 py-3 text-muted-foreground font-mono text-xs">{p.sku || '—'}</td>
                  <td className="px-4 py-3 text-muted-foreground">{p.category_name || '—'}</td>
                  <td className="px-4 py-3">
                    <span className="flex items-center gap-1 text-red-600 font-bold">
                      <AlertTriangle className="w-3 h-3" />{p.current_stock}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-muted-foreground">{p.minimum_stock}</td>
                  <td className="px-4 py-3">{KES(p.selling_price)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
