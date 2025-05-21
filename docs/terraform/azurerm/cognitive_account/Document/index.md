---
sidebar_position: 1
---

# Document

### Index

- [What is it?](#What-is-it?)
- [Purpose](#purpose)
- [Key Details](#key-details)

### What is it?

This resource creates and manages an Azure Cognitive Services account in Terraform.

### Purpose

Azure Cognitive Services provide pre-built AI models for vision, speech, language, and decision-making capabilities. This account lets you use those AI APIs, like Computer Vision, Text Analytics, Face API, Translator, etc.

### Key Details

- You provision a cognitive account specifying SKU, location, and which services it supports (e.g., Text Analytics, Speech).
- The resource creates keys and endpoints to call the AI services.
- You can enable individual cognitive capabilities inside this account or create multiple accounts for different workloads.