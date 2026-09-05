'use client'

import { useEffect, useState } from 'react'
import { Plus, Loader2 } from 'lucide-react'
import { api } from '@/lib/api'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'

interface Movement { id: number; product_name: string; type: string; quantity: number; previous_stock: number; new_stock: number; reason: string; movement_date: string }
interface Product { id: number; name: string }

const TYPE_COLOR: Record<string, string> = {
  purchase: 'bg-green-100 text-green-700', sale: 'bg-blue-100 text-blue-700',
  adjustment: 'bg-yellow-100 text-yellow-700', damage: 'bg-red-100 text-red-700',
  return: 'bg-purple-100 text-purple-700', transfer: 'bg-slate-100 text-slate-700',
}

export default function StockPage() {
  const [movements, setMovements] = useState<Movement[]>([])
  const [products, setProducts]   = useState<Product[]>([])
  const [loading, setLoading]     = useState(true)
  const [open, setOpen]           = useState(false)
  const [saving, setSaving]       = useState(false)
  const [form, setForm]           = useState({ product_id: '', type: 'purchase', quantity: '', reason: '' })

  const load = () => {
    Promise.all([
      api.get<{ success: boolean; movements: Movement[] }>('stock/index.php'),
      api.get<{ success: boolean; products: Product[] }>('products/index.php'),
    ]).then(([sm, sp]) => {
      setMovements(sm.movements || [])
      setProducts(sp.products || [])
    }).catch(() => toast.error('Failed to load')).finally(() => setLoading(false))
  }
  useEffect(load, [])

  async function handleSave() {
    if (!form.product_id || !form.quantity) return toast.error('Product and quantity required')
    setSaving(true)
    try {
      const res = await api.post<{ success: boolean; message: string }>('stock/index.php', {
        product_id: parseInt(form.product_id),
        type: form.type,
        quantity: parseFloat(form.quantity),
        reason: form.reason,
      })
      if (res.success) { toast.success('Stock updated'); setOpen(false); setForm({ product_id:'', type:'purchase', quantity:'', reason:'' }); load() }
      else toast.error(res.message)
    } catch { toast.error('Failed') } finally { setSaving(false) }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold">Stock Movements</h1><p className="text-muted-foreground text-sm">{movements.length} records</p></div>
        <Button onClick={() => setOpen(true)} className="bg-indigo-600 hover:bg-indigo-500 text-white"><Plus className="w-4 h-4 mr-1" />Adjust Stock</Button>
      </div>

      {loading ? (
        <div className="space-y-2">{Array.from({length:6}).map((_,i) => <div key={i} className="h-12 rounded-lg bg-muted animate-pulse" />)}</div>
      ) : (
        <div className="rounded-xl border overflow-hidden bg-white dark:bg-slate-900">
          <table className="w-full text-sm">
            <thead className="border-b bg-slate-50 dark:bg-slate-800">
              <tr>{['Product','Type','Qty','Before','After','Reason','Date'].map(h => (
                <th key={h} className="text-left px-4 py-3 text-xs font-medium text-muted-foreground uppercase tracking-wide">{h}</th>
              ))}</tr>
            </thead>
            <tbody>
              {movements.length === 0
                ? <tr><td colSpan={7} className="text-center py-12 text-muted-foreground">No movements yet</td></tr>
                : movements.map(m => (
                  <tr key={m.id} className="border-b last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                    <td className="px-4 py-3 font-medium">{m.product_name}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-xs font-medium capitalize ${TYPE_COLOR[m.type] || ''}`}>{m.type}</span>
                    </td>
                    <td className="px-4 py-3 font-mono">{m.quantity > 0 ? `+${m.quantity}` : m.quantity}</td>
                    <td className="px-4 py-3 text-muted-foreground">{m.previous_stock}</td>
                    <td className="px-4 py-3 font-semibold">{m.new_stock}</td>
                    <td className="px-4 py-3 text-muted-foreground text-xs truncate max-w-[120px]">{m.reason || '—'}</td>
                    <td className="px-4 py-3 text-muted-foreground text-xs">{new Date(m.movement_date).toLocaleDateString('en-KE')}</td>
                  </tr>
                ))
              }
            </tbody>
          </table>
        </div>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader><DialogTitle>Adjust Stock</DialogTitle></DialogHeader>
          <div className="space-y-3">
            <div className="space-y-1">
              <Label className="text-xs">Product *</Label>
              <Select value={form.product_id} onValueChange={v => setForm(f => ({...f, product_id: v}))}>
                <SelectTrigger><SelectValue placeholder="Select product" /></SelectTrigger>
                <SelectContent>{products.map(p => <SelectItem key={p.id} value={String(p.id)}>{p.name}</SelectItem>)}</SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Type</Label>
                <Select value={form.type} onValueChange={v => setForm(f => ({...f, type: v}))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {['purchase','adjustment','return','damage','transfer'].map(t => <SelectItem key={t} value={t} className="capitalize">{t}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1">
                <Label className="text-xs">Quantity *</Label>
                <Input type="number" value={form.quantity} onChange={e => setForm(f => ({...f, quantity: e.target.value}))} placeholder="0" />
              </div>
            </div>
            <div className="space-y-1">
              <Label className="text-xs">Reason / Note</Label>
              <Input value={form.reason} onChange={e => setForm(f => ({...f, reason: e.target.value}))} placeholder="Optional" />
            </div>
          </div>
          <DialogFooter className="mt-2">
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button className="bg-indigo-600 hover:bg-indigo-500 text-white" onClick={handleSave} disabled={saving}>
              {saving ? <><Loader2 className="w-4 h-4 mr-1 animate-spin" />Saving…</> : 'Save'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
