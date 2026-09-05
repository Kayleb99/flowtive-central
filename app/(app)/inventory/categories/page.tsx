'use client'

import { useEffect, useState } from 'react'
import { Plus } from 'lucide-react'
import { api } from '@/lib/api'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'

interface Category { id: number; name: string; icon: string; color: string; description: string }

export default function CategoriesPage() {
  const [cats, setCats]     = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [open, setOpen]       = useState(false)
  const [saving, setSaving]   = useState(false)
  const [form, setForm]       = useState({ name: '', icon: 'fa-box', color: '#667eea', description: '' })

  const load = () => {
    api.get<{ success: boolean; categories: Category[] }>('categories/index.php')
      .then(r => setCats(r.categories || []))
      .catch(() => {})
      .finally(() => setLoading(false))
  }
  useEffect(load, [])

  async function handleSave() {
    if (!form.name) return toast.error('Name required')
    setSaving(true)
    try {
      const res = await api.post<{ success: boolean; message: string }>('categories/index.php', form)
      if (res.success) { toast.success('Category added'); setOpen(false); setForm({ name:'', icon:'fa-box', color:'#667eea', description:'' }); load() }
      else toast.error(res.message)
    } catch { toast.error('Failed') } finally { setSaving(false) }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold">Categories</h1><p className="text-muted-foreground text-sm">{cats.length} categories</p></div>
        <Button onClick={() => setOpen(true)} className="bg-indigo-600 hover:bg-indigo-500 text-white"><Plus className="w-4 h-4 mr-1" />Add</Button>
      </div>

      {loading ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">{Array.from({length:6}).map((_,i) => <div key={i} className="h-24 rounded-xl bg-muted animate-pulse" />)}</div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          {cats.map(c => (
            <div key={c.id} className="rounded-xl border bg-white dark:bg-slate-900 p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg flex items-center justify-center shrink-0" style={{ backgroundColor: c.color + '22' }}>
                <div className="w-4 h-4 rounded-full" style={{ backgroundColor: c.color }} />
              </div>
              <div className="min-w-0">
                <p className="font-medium truncate">{c.name}</p>
                <p className="text-xs text-muted-foreground truncate">{c.description || 'No description'}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader><DialogTitle>Add Category</DialogTitle></DialogHeader>
          <div className="space-y-3">
            <div className="space-y-1"><Label className="text-xs">Name *</Label><Input value={form.name} onChange={e => setForm(f => ({...f, name: e.target.value}))} placeholder="e.g. Fabrics" /></div>
            <div className="space-y-1"><Label className="text-xs">Color</Label><Input type="color" value={form.color} onChange={e => setForm(f => ({...f, color: e.target.value}))} className="h-10 p-1" /></div>
            <div className="space-y-1"><Label className="text-xs">Description</Label><Input value={form.description} onChange={e => setForm(f => ({...f, description: e.target.value}))} placeholder="Optional" /></div>
          </div>
          <DialogFooter className="mt-2">
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button className="bg-indigo-600 hover:bg-indigo-500 text-white" onClick={handleSave} disabled={saving}>{saving ? 'Saving…' : 'Add'}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
