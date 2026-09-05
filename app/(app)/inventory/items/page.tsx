'use client'

import { useEffect, useState } from 'react'
import { Search, Plus, Package, AlertTriangle } from 'lucide-react'
import { api } from '@/lib/api'
import { toast } from 'sonner'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'

interface Product { id: number; name: string; sku: string; category_name: string; selling_price: number; current_stock: number; minimum_stock: number; status: string }

const KES = (n: number) => `KES ${(n||0).toLocaleString('en-KE', { minimumFractionDigits: 2 })}`

export default function ItemsPage() {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading]   = useState(true)
  const [query, setQuery]       = useState('')
  const [open, setOpen]         = useState(false)
  const [saving, setSaving]     = useState(false)
  const [form, setForm]         = useState({ name: '', sku: '', selling_price: '', cost_price: '', current_stock: '', minimum_stock: '' })

  const load = () => {
    setLoading(true)
    api.get<{ success: boolean; products: Product[] }>('products/index.php')
      .then(r => setProducts(r.products || []))
      .catch(() => toast.error('Failed to load products'))
      .finally(() => setLoading(false))
  }

  useEffect(load, [])

  const filtered = products.filter(p =>
    !query || p.name.toLowerCase().includes(query.toLowerCase()) || p.sku?.toLowerCase().includes(query.toLowerCase())
  )

  async function handleSave() {
    if (!form.name) return toast.error('Product name is required')
    setSaving(true)
    try {
      const res = await api.post<{ success: boolean; message: string }>('products/index.php', {
        name: form.name, sku: form.sku,
        selling_price: parseFloat(form.selling_price) || 0,
        cost_price:    parseFloat(form.cost_price) || 0,
        current_stock: parseFloat(form.current_stock) || 0,
        minimum_stock: parseFloat(form.minimum_stock) || 0,
        status: 'active',
      })
      if (res.success) { toast.success('Product added'); setOpen(false); setForm({ name:'',sku:'',selling_price:'',cost_price:'',current_stock:'',minimum_stock:'' }); load() }
      else toast.error(res.message)
    } catch (e: unknown) { toast.error((e as { message?: string }).message || 'Error') }
    finally { setSaving(false) }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Products</h1>
          <p className="text-muted-foreground text-sm">{products.length} items</p>
        </div>
        <Button onClick={() => setOpen(true)} className="bg-indigo-600 hover:bg-indigo-500 text-white">
          <Plus className="w-4 h-4 mr-1" /> Add Product
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Search products…" className="pl-9" value={query} onChange={e => setQuery(e.target.value)} />
      </div>

      {loading ? (
        <div className="space-y-2">{Array.from({length:6}).map((_,i) => <div key={i} className="h-14 rounded-lg bg-muted animate-pulse" />)}</div>
      ) : (
        <div className="rounded-xl border overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="border-b bg-slate-50 dark:bg-slate-800">
              <tr>{['Product','SKU','Category','Price','Stock','Status'].map(h => (
                <th key={h} className="text-left px-4 py-3 text-xs font-medium text-muted-foreground uppercase tracking-wide">{h}</th>
              ))}</tr>
            </thead>
            <tbody>
              {filtered.length === 0
                ? <tr><td colSpan={6} className="text-center py-12 text-muted-foreground">No products found</td></tr>
                : filtered.map(p => (
                  <tr key={p.id} className="border-b last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                    <td className="px-4 py-3 font-medium">{p.name}</td>
                    <td className="px-4 py-3 text-muted-foreground font-mono text-xs">{p.sku || '—'}</td>
                    <td className="px-4 py-3 text-muted-foreground">{p.category_name || '—'}</td>
                    <td className="px-4 py-3 font-semibold">{KES(p.selling_price)}</td>
                    <td className="px-4 py-3">
                      <span className={`flex items-center gap-1 text-sm ${p.current_stock <= p.minimum_stock ? 'text-red-500 font-semibold' : ''}`}>
                        {p.current_stock <= p.minimum_stock && <AlertTriangle className="w-3 h-3" />}
                        {p.current_stock}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-xs font-medium capitalize ${p.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-600'}`}>
                        {p.status}
                      </span>
                    </td>
                  </tr>
                ))
              }
            </tbody>
          </table>
        </div>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>Add Product</DialogTitle></DialogHeader>
          <div className="grid grid-cols-2 gap-3">
            <div className="col-span-2 space-y-1">
              <Label className="text-xs">Name *</Label>
              <Input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} placeholder="e.g. Cotton Fabric" />
            </div>
            <div className="space-y-1">
              <Label className="text-xs">SKU</Label>
              <Input value={form.sku} onChange={e => setForm(f => ({ ...f, sku: e.target.value }))} placeholder="FAB-001" />
            </div>
            <div className="space-y-1">
              <Label className="text-xs">Selling Price (KES)</Label>
              <Input type="number" value={form.selling_price} onChange={e => setForm(f => ({ ...f, selling_price: e.target.value }))} placeholder="0.00" />
            </div>
            <div className="space-y-1">
              <Label className="text-xs">Cost Price (KES)</Label>
              <Input type="number" value={form.cost_price} onChange={e => setForm(f => ({ ...f, cost_price: e.target.value }))} placeholder="0.00" />
            </div>
            <div className="space-y-1">
              <Label className="text-xs">Opening Stock</Label>
              <Input type="number" value={form.current_stock} onChange={e => setForm(f => ({ ...f, current_stock: e.target.value }))} placeholder="0" />
            </div>
            <div className="space-y-1 col-span-2">
              <Label className="text-xs">Min Stock Alert</Label>
              <Input type="number" value={form.minimum_stock} onChange={e => setForm(f => ({ ...f, minimum_stock: e.target.value }))} placeholder="5" />
            </div>
          </div>
          <DialogFooter className="mt-2">
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button className="bg-indigo-600 hover:bg-indigo-500 text-white" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving…' : 'Add Product'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
