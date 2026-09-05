'use client'

import { useEffect, useState, useCallback } from 'react'
import { Plus, Minus, Trash2, Search, Loader2, Smartphone } from 'lucide-react'
import { api } from '@/lib/api'
import { getStoredUser } from '@/lib/auth'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

interface Product { id: number; name: string; sku: string; selling_price: number; current_stock: number; units_of_sale?: { unit_label: string; selling_price: number; conversion_to_base: number }[] }
interface CartItem { product_id: number; product_name: string; unit_label: string; unit_price: number; quantity: number; discount: number; conversion_to_base: number }

const KES = (n: number) => `KES ${n.toLocaleString('en-KE', { minimumFractionDigits: 2 })}`

export default function NewOrderPage() {
  const [products, setProducts]         = useState<Product[]>([])
  const [query,    setQuery]            = useState('')
  const [cart,     setCart]             = useState<CartItem[]>([])
  const [customer, setCustomer]         = useState({ name: '', mobile: '' })
  const [payMethod,setPayMethod]        = useState('cash')
  const [splitCash,setSplitCash]        = useState('')
  const [mpesaCode,setMpesaCode]        = useState('')
  const [checkoutOpen, setCheckoutOpen] = useState(false)
  const [submitting, setSubmitting]     = useState(false)

  const user = getStoredUser()

  useEffect(() => {
    api.get<{ success: boolean; products: Product[] }>('products/index.php')
      .then(r => setProducts(r.products || []))
      .catch(() => toast.error('Failed to load products'))
  }, [])

  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase()) ||
    p.sku?.toLowerCase().includes(query.toLowerCase())
  )

  function addToCart(product: Product, unitLabel?: string, unitPrice?: number, conversionToBase?: number) {
    const label = unitLabel || 'piece'
    const price = unitPrice ?? product.selling_price
    const conv  = conversionToBase ?? 1
    setCart(prev => {
      const idx = prev.findIndex(i => i.product_id === product.id && i.unit_label === label)
      if (idx >= 0) {
        const next = [...prev]; next[idx] = { ...next[idx], quantity: next[idx].quantity + 1 }; return next
      }
      return [...prev, { product_id: product.id, product_name: product.name, unit_label: label, unit_price: price, quantity: 1, discount: 0, conversion_to_base: conv }]
    })
  }

  function updateQty(idx: number, delta: number) {
    setCart(prev => {
      const next = [...prev]
      next[idx] = { ...next[idx], quantity: Math.max(0, next[idx].quantity + delta) }
      return next[idx].quantity === 0 ? next.filter((_, i) => i !== idx) : next
    })
  }

  function updateDiscount(idx: number, val: string) {
    setCart(prev => { const next = [...prev]; next[idx] = { ...next[idx], discount: parseFloat(val) || 0 }; return next })
  }

  const subtotal  = cart.reduce((s, i) => s + (i.unit_price * i.quantity) - i.discount, 0)
  const splitMobile = payMethod === 'split' ? subtotal - (parseFloat(splitCash) || 0) : 0

  async function handleCheckout() {
    if (!cart.length) return toast.error('Cart is empty')
    setSubmitting(true)
    try {
      const items = cart.map(i => ({
        product_id: i.product_id, product_name: i.product_name,
        unit_label: i.unit_label, unit_price: i.unit_price,
        quantity: i.quantity, discount: i.discount,
        total: (i.unit_price * i.quantity) - i.discount,
        base_quantity: i.quantity * i.conversion_to_base,
      }))

      const res = await api.post<{ success: boolean; message: string; sale?: { order_number: string } }>(
        'sales/index.php',
        {
          customer_name: customer.name || 'Walk-in',
          customer_mobile: customer.mobile,
          user_id: user?.id,
          items,
          subtotal,
          total: subtotal,
          payment_method: payMethod,
          split_cash:  payMethod === 'split' ? parseFloat(splitCash) : undefined,
          split_mobile: payMethod === 'split' ? splitMobile : undefined,
          mpesa_code:  ['mobile','split'].includes(payMethod) ? mpesaCode : undefined,
          payment_status: 'paid',
          amount_paid: subtotal,
          amount_due: 0,
        }
      )

      if (res.success) {
        toast.success(`Sale #${res.sale?.order_number} recorded!`)
        setCart([]); setCustomer({ name: '', mobile: '' }); setMpesaCode(''); setSplitCash('')
        setCheckoutOpen(false)
      } else {
        toast.error(res.message || 'Sale failed')
      }
    } catch (e: unknown) {
      toast.error((e as { message?: string }).message || 'Network error')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="grid lg:grid-cols-[1fr_380px] gap-6 h-[calc(100vh-7rem)]">
      {/* Products panel */}
      <div className="flex flex-col gap-4 min-h-0">
        <div className="flex items-center gap-2">
          <Search className="w-4 h-4 text-muted-foreground absolute ml-3 pointer-events-none" />
          <Input placeholder="Search products…" className="pl-9" value={query} onChange={e => setQuery(e.target.value)} />
        </div>
        <div className="flex-1 overflow-y-auto grid grid-cols-2 sm:grid-cols-3 gap-3 content-start">
          {filtered.map(p => (
            <button
              key={p.id}
              onClick={() => {
                if (p.units_of_sale?.length) {
                  addToCart(p, p.units_of_sale[0].unit_label, p.units_of_sale[0].selling_price, p.units_of_sale[0].conversion_to_base)
                } else {
                  addToCart(p)
                }
              }}
              className="text-left rounded-xl border bg-white dark:bg-slate-900 p-3 hover:border-indigo-500 hover:shadow-sm transition-all"
            >
              <p className="text-sm font-medium line-clamp-2">{p.name}</p>
              <p className="text-xs text-muted-foreground mt-1">{p.sku}</p>
              <p className="text-indigo-600 font-semibold text-sm mt-2">{KES(p.selling_price)}</p>
              <p className="text-xs text-muted-foreground">Stock: {p.current_stock}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Cart panel */}
      <div className="flex flex-col gap-3 border rounded-2xl bg-white dark:bg-slate-900 p-4 min-h-0">
        <h2 className="font-semibold text-sm">Cart ({cart.length} items)</h2>

        <div className="flex-1 overflow-y-auto space-y-2">
          {cart.length === 0 && (
            <p className="text-muted-foreground text-sm text-center py-10">Add products from the left</p>
          )}
          {cart.map((item, idx) => (
            <div key={idx} className="flex items-center gap-2 text-sm border-b pb-2">
              <div className="flex-1 min-w-0">
                <p className="font-medium truncate">{item.product_name}</p>
                <p className="text-xs text-muted-foreground">{item.unit_label} · {KES(item.unit_price)}</p>
              </div>
              <div className="flex items-center gap-1">
                <button onClick={() => updateQty(idx, -1)} className="w-6 h-6 rounded border flex items-center justify-center hover:bg-slate-100"><Minus className="w-3 h-3" /></button>
                <span className="w-6 text-center">{item.quantity}</span>
                <button onClick={() => updateQty(idx, +1)} className="w-6 h-6 rounded border flex items-center justify-center hover:bg-slate-100"><Plus className="w-3 h-3" /></button>
              </div>
              <span className="w-20 text-right font-medium">{KES(item.unit_price * item.quantity - item.discount)}</span>
              <button onClick={() => setCart(prev => prev.filter((_, i) => i !== idx))} className="text-red-400 hover:text-red-600">
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>

        <div className="border-t pt-3 space-y-1 text-sm">
          <div className="flex justify-between font-bold text-base">
            <span>Total</span><span>{KES(subtotal)}</span>
          </div>
        </div>

        <Button
          className="w-full bg-indigo-600 hover:bg-indigo-500 text-white"
          disabled={!cart.length}
          onClick={() => setCheckoutOpen(true)}
        >
          Checkout
        </Button>
      </div>

      {/* Checkout dialog */}
      <Dialog open={checkoutOpen} onOpenChange={setCheckoutOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>Complete Sale</DialogTitle></DialogHeader>

          <div className="space-y-4">
            {/* Customer */}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label className="text-xs">Customer Name</Label>
                <Input placeholder="Walk-in" value={customer.name} onChange={e => setCustomer(c => ({ ...c, name: e.target.value }))} />
              </div>
              <div>
                <Label className="text-xs">Mobile</Label>
                <Input placeholder="07xx xxx xxx" value={customer.mobile} onChange={e => setCustomer(c => ({ ...c, mobile: e.target.value }))} />
              </div>
            </div>

            {/* Payment method */}
            <div>
              <Label className="text-xs">Payment Method</Label>
              <Tabs value={payMethod} onValueChange={setPayMethod}>
                <TabsList className="w-full">
                  <TabsTrigger value="cash"   className="flex-1">Cash</TabsTrigger>
                  <TabsTrigger value="mobile" className="flex-1">M-Pesa</TabsTrigger>
                  <TabsTrigger value="split"  className="flex-1">Split</TabsTrigger>
                  <TabsTrigger value="debt"   className="flex-1">Debt</TabsTrigger>
                </TabsList>

                <TabsContent value="mobile" className="mt-3">
                  <div className="flex items-center gap-2 bg-green-50 dark:bg-green-950 border border-green-200 dark:border-green-800 rounded-lg p-3">
                    <Smartphone className="w-4 h-4 text-green-600 shrink-0" />
                    <div className="flex-1">
                      <p className="text-xs font-medium text-green-700 dark:text-green-400">Manual M-Pesa</p>
                      <Input
                        placeholder="M-Pesa code e.g. QH38KL9F21"
                        className="mt-1 uppercase bg-white dark:bg-slate-900"
                        value={mpesaCode}
                        onChange={e => setMpesaCode(e.target.value.toUpperCase())}
                      />
                    </div>
                  </div>
                </TabsContent>

                <TabsContent value="split" className="mt-3 space-y-3">
                  <div>
                    <Label className="text-xs">Cash Amount</Label>
                    <Input type="number" placeholder="0" value={splitCash} onChange={e => setSplitCash(e.target.value)} />
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">M-Pesa balance:</span>
                    <span className="font-medium">{KES(splitMobile)}</span>
                  </div>
                  <Input
                    placeholder="M-Pesa code for mobile portion"
                    className="uppercase"
                    value={mpesaCode}
                    onChange={e => setMpesaCode(e.target.value.toUpperCase())}
                  />
                </TabsContent>
              </Tabs>
            </div>

            {/* Summary */}
            <div className="bg-slate-50 dark:bg-slate-800 rounded-lg p-3 space-y-1 text-sm">
              <div className="flex justify-between"><span>Items</span><span>{cart.length}</span></div>
              <div className="flex justify-between font-bold text-base border-t pt-1 mt-1">
                <span>Total</span><span>{KES(subtotal)}</span>
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setCheckoutOpen(false)}>Cancel</Button>
            <Button
              className="bg-indigo-600 hover:bg-indigo-500 text-white"
              onClick={handleCheckout}
              disabled={submitting}
            >
              {submitting ? <><Loader2 className="w-4 h-4 mr-2 animate-spin" />Processing…</> : 'Confirm Sale'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
