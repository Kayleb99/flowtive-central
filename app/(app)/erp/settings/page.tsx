'use client'

import { useState } from 'react'
import { toast } from 'sonner'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Loader2 } from 'lucide-react'

export default function SettingsPage() {
  const [saving, setSaving] = useState(false)
  const [mpesaMode, setMpesaMode] = useState('manual')

  const handleSave = () => {
    setSaving(true)
    setTimeout(() => {
      setSaving(false)
      toast.success('Settings updated successfully')
    }, 1000)
  }

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-2xl font-bold">System Settings</h1>
        <p className="text-muted-foreground text-sm">Manage your business and integration preferences</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Business Profile</CardTitle>
          <CardDescription>Details displayed on receipts and reports.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1"><Label>Business Name</Label><Input defaultValue="Flowtive Supermarket" /></div>
            <div className="space-y-1"><Label>Currency Symbol</Label><Input defaultValue="KES" /></div>
            <div className="space-y-1"><Label>Contact Phone</Label><Input defaultValue="0700 000 000" /></div>
            <div className="space-y-1"><Label>Location</Label><Input defaultValue="Nairobi, Kenya" /></div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>M-Pesa Integration</CardTitle>
          <CardDescription>Configure how M-Pesa payments are processed.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-1">
            <Label>Operating Mode</Label>
            <Select value={mpesaMode} onValueChange={setMpesaMode}>
              <SelectTrigger><SelectValue/></SelectTrigger>
              <SelectContent>
                <SelectItem value="manual">Manual (Cashier verifies message)</SelectItem>
                <SelectItem value="daraja">Daraja API (Auto STK Push)</SelectItem>
                <SelectItem value="off">Disabled</SelectItem>
              </SelectContent>
            </Select>
          </div>
          {mpesaMode === 'daraja' && (
            <div className="grid grid-cols-2 gap-4 p-4 bg-slate-50 dark:bg-slate-900 rounded-lg border">
              <div className="space-y-1"><Label>Shortcode / Till</Label><Input placeholder="e.g. 174379" /></div>
              <div className="space-y-1"><Label>Passkey</Label><Input type="password" placeholder="***" /></div>
              <div className="space-y-1"><Label>Consumer Key</Label><Input type="password" placeholder="***" /></div>
              <div className="space-y-1"><Label>Consumer Secret</Label><Input type="password" placeholder="***" /></div>
            </div>
          )}
        </CardContent>
      </Card>

      <Button onClick={handleSave} disabled={saving} className="bg-indigo-600 hover:bg-indigo-500 text-white">
        {saving ? <><Loader2 className="w-4 h-4 mr-2 animate-spin"/> Saving...</> : 'Save Settings'}
      </Button>
    </div>
  )
}
