import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthlyButton", "yearlyButton", "monthlyPrice", "yearlyPrice"]

  connect() {
    // Initialize with monthly pricing active
    this.showMonthly()
  }

  showMonthly() {
    // Update button states
    this.monthlyButtonTarget.classList.add('active', 'bg-white', 'text-slate-900', 'shadow-sm')
    this.monthlyButtonTarget.classList.remove('text-slate-600')
    this.yearlyButtonTarget.classList.remove('active', 'bg-white', 'text-slate-900', 'shadow-sm')
    this.yearlyButtonTarget.classList.add('text-slate-600')

    // Show monthly prices, hide yearly prices
    this.monthlyPriceTargets.forEach(price => price.classList.remove('hidden'))
    this.yearlyPriceTargets.forEach(price => price.classList.add('hidden'))
  }

  showYearly() {
    // Update button states
    this.yearlyButtonTarget.classList.add('active', 'bg-white', 'text-slate-900', 'shadow-sm')
    this.yearlyButtonTarget.classList.remove('text-slate-600')
    this.monthlyButtonTarget.classList.remove('active', 'bg-white', 'text-slate-900', 'shadow-sm')
    this.monthlyButtonTarget.classList.add('text-slate-600')

    // Show yearly prices, hide monthly prices
    this.yearlyPriceTargets.forEach(price => price.classList.remove('hidden'))
    this.monthlyPriceTargets.forEach(price => price.classList.add('hidden'))
  }
}
