# ♻️ Kollekt

### A Transparent, Traceable & Inclusive E-Waste Collection Platform

Kollekt is a mobile-first e-waste collection platform designed to bridge the gap between **informal e-waste collectors** and **authorized recyclers**.

The platform enables collectors to identify and record e-waste, discover transparent market prices, create waste lots, compare recycler offers, complete transactions, and maintain a traceable record of the material handover.

Kollekt is designed with a focus on **simplicity, transparency, accessibility, and traceability**, particularly for users operating within the informal e-waste collection ecosystem.

---

## 🎯 Problem

A large portion of India's end-of-life electronics is collected through informal scrap dealers, waste-pickers, and local aggregators.

While these collectors provide critical last-mile collection infrastructure, they often face:

- Lack of transparent and reliable material prices
- Dependence on intermediaries
- Limited access to authorized recyclers
- Difficulty comparing offers
- Poor transaction records
- Lack of traceability after handover
- Limited access to digital tools
- Language and literacy barriers

This creates an ecosystem where collectors may receive inconsistent prices and where the movement of e-waste is difficult to track.

---

## 💡 Our Solution

Kollekt provides a digital bridge between collectors and authorized recyclers.

The platform allows a collector to:

1. 📸 Capture an image of e-waste
2. 🤖 Classify the material
3. ⚖️ Enter the approximate weight
4. 💰 View estimated material value
5. 📊 Explore historical price trends
6. 📦 Create a digital waste lot
7. 🏭 Receive offers from recyclers
8. ⚖️ Compare multiple offers
9. ✅ Select the preferred offer
10. 💵 Track earnings
11. 🔗 Track the material handover and transaction history

The goal is to make the recycling process **more transparent, competitive, and traceable**.

---

# 🚀 Key Features

## 👤 Collector

### 📸 E-Waste Capture

Collectors can use the device camera to capture an image of the waste material.

The captured image becomes part of the digital waste lot record.

---

### 🤖 Material Classification

The prototype includes a material classification module that identifies the likely material category from the captured waste.

The current prototype uses a deterministic/demo classifier to demonstrate the intended workflow.

The architecture can later be extended to a trained computer vision model.

---

### 💰 Price Discovery

Collectors can view current indicative buying prices for different e-waste materials.

The price board provides:

- Material category
- Current buying rate
- Approximate market range
- Unit of measurement

This helps collectors understand the approximate market value before accepting an offer.

---

### 📊 Price History

Kollekt provides historical price information through a visual trend graph.

This enables collectors to understand how material prices change over time.

The prototype currently uses seeded/demo historical data.

In the production system, completed transactions can continuously contribute to the historical price dataset.

---

### 📦 Digital Waste Lots

Collectors can create a digital lot containing:

- Material
- Description
- Approximate weight
- Location
- Estimated value
- Waste photograph
- Creation timestamp
- Lot status

Each lot receives a unique Firestore document ID.

---

### 🏭 Recycler Offer Comparison

Authorized recyclers can submit offers for available waste lots.

Collectors can compare offers based on the offered price and choose the offer that provides the best value.

---

### 💵 Earnings

Collectors can view completed transactions and payments associated with their lots.

This creates a simple digital earnings record instead of relying only on informal cash-based records.

---

### 🔗 Traceability

Kollekt maintains a digital trail connecting:

```text
Collector
    ↓
Waste Lot
    ↓
Recycler Offer
    ↓
Accepted Offer
    ↓
Transaction
    ↓
Handover
