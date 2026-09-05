'use client'

import { useEffect, useState } from 'react'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, CartesianGrid } from 'recharts'
import { DollarSign, ShoppingCart, TrendingUp, Users } from 'lucide-react'
import { api } from '@/lib/api'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export default function ERPDashboard() {
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<any>('dashboard/index.php')
      .then(r => setStats(r.stats))
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const fmt = (n: number) => `KES ${(n||0).toLocaleString('en-KE')}`
  const mockData = [
    { name: 'Mon', revenue: 4000 }, { name: 'Tue', revenue: 3000 },
    { name: 'Wed', revenue: 5000 }, { name: 'Thu', revenue: 2780 },
    { name: 'Fri', revenue: 6890 }, { name: 'Sat', revenue: 8390 },
    { name: 'Sun', revenue: 3490 },
  ]

  if (loading) return <div className="animate-pulse space-y-4"><div className="h-32 bg-muted rounded-xl"/><div className="h-64 bg-muted rounded-xl"/></div>

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Central ERP Hub</h1>
        <p className="text-muted-foreground text-sm">Business Overview</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Card><CardContent className="p-5 flex items-center gap-4"><div className="p-3 rounded-xl bg-blue-500"><DollarSign className="w-5 h-5 text-white"/></div><div><p className="text-sm text-muted-foreground">Revenue</p><p className="text-2xl font-bold">{fmt(stats?.today_revenue)}</p></div></CardContent></Card>
        <Card><CardContent className="p-5 flex items-center gap-4"><div className="p-3 rounded-xl bg-green-500"><TrendingUp className="w-5 h-5 text-white"/></div><div><p className="text-sm text-muted-foreground">Profit</p><p className="text-2xl font-bold">{fmt(stats?.today_profit)}</p></div></CardContent></Card>
        <Card><CardContent className="p-5 flex items-center gap-4"><div className="p-3 rounded-xl bg-indigo-500"><ShoppingCart className="w-5 h-5 text-white"/></div><div><p className="text-sm text-muted-foreground">Sales</p><p className="text-2xl font-bold">{stats?.today_sales||0}</p></div></CardContent></Card>
        <Card><CardContent className="p-5 flex items-center gap-4"><div className="p-3 rounded-xl bg-orange-500"><Users className="w-5 h-5 text-white"/></div><div><p className="text-sm text-muted-foreground">Customers</p><p className="text-2xl font-bold">{stats?.total_customers||0}</p></div></CardContent></Card>
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader><CardTitle>Revenue (Last 7 Days)</CardTitle></CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={mockData}><CartesianGrid strokeDasharray="3 3" vertical={false}/><XAxis dataKey="name" fontSize={12} tickLine={false} axisLine={false}/><YAxis fontSize={12} tickLine={false} axisLine={false} tickFormatter={v => `K ${v/1000}`}/><Tooltip cursor={{fill:'transparent'}}/><Bar dataKey="revenue" fill="#4f46e5" radius={[4,4,0,0]} /></BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>Profit Trend</CardTitle></CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={mockData}><CartesianGrid strokeDasharray="3 3" vertical={false}/><XAxis dataKey="name" fontSize={12} tickLine={false} axisLine={false}/><YAxis fontSize={12} tickLine={false} axisLine={false}/><Tooltip/><Line type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={3} dot={false}/></LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
