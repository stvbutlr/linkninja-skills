# ICP-to-Keyword Extraction Guide

How to translate an ICP description into headline keywords for `scan_connections`. The ICP describes who the user sells to. Headlines describe who the person is. This table maps one to the other.

## Core Translation Table

| ICP Element | Headline Signal | Keyword Examples |
|-------------|----------------|-----------------|
| Job title / role | Direct title match | "VP Sales", "Head of Growth", "CRO", "Founder", "CEO", "COO" |
| Industry / sector | Company or sector terms | "SaaS", "FinTech", "Construction", "Healthcare", "EdTech" |
| Company stage | Stage indicators | "Series A", "Startup", "Scale-up", "Pre-seed", "Growth-stage" |
| Seniority | Level markers | "Director", "Chief", "SVP", "Partner", "Senior", "Lead" |
| Function | Department signals | "Revenue", "Marketing", "Engineering", "Operations", "People" |
| Ownership | Business owner signals | "Founder", "Owner", "Co-Founder", "Managing Director", "Principal" |

## Include Keywords: Expansion Patterns

When the initial scan is too narrow, expand with adjacent terms.

### Title Expansions

| Core Title | Adjacent Titles |
|-----------|----------------|
| Founder | Co-Founder, CEO, Managing Director, Owner, Principal |
| VP Sales | Sales Director, Head of Revenue, CRO, Head of Sales, Sales Leader |
| Head of Marketing | Marketing Director, CMO, VP Marketing, Growth Lead |
| CTO | VP Engineering, Head of Engineering, Technical Director |
| Consultant | Advisor, Strategist, Specialist, Expert, Practitioner |
| Coach | Mentor, Facilitator, Trainer, Guide |
| Agency Owner | Creative Director, Managing Partner, Agency Founder |

### Industry Expansions

| Core Term | Adjacent Terms |
|----------|---------------|
| SaaS | Software, Platform, Cloud, Tech, Digital |
| FinTech | Financial Technology, Banking, Payments, InsurTech |
| Healthcare | MedTech, Health Tech, Digital Health, Clinical |
| EdTech | Education, Learning, Training, Curriculum |
| Construction | Building, Property, Real Estate, Infrastructure |
| Recruiting | Talent, Staffing, HR, People Operations |

### Seniority Expansions

| Core Level | Adjacent Levels |
|-----------|----------------|
| C-Suite | CEO, CTO, CFO, COO, CMO, CRO, CPO |
| VP | SVP, EVP, Vice President, Head of |
| Director | Senior Director, Associate Director, Managing Director |
| Manager | Senior Manager, Team Lead, Head of |

## Exclude Keywords: Common Filters

### Always Consider Excluding

| Keyword | Why |
|---------|-----|
| "Student" | Not a buyer |
| "Intern" | Not a decision maker |
| "Looking for" / "Seeking" | Job seekers, not buyers |
| "Open to work" | Job seekers |
| "Retired" | Unless targeting for advisory/consulting |
| "Recruiter" | Usually selling to you, not buying |

### Situational Excludes

| Exclude When | Keywords to Add |
|-------------|----------------|
| Targeting operators, not investors | "Investor", "VC", "Angel", "Board Member" |
| Targeting buyers, not sellers | "Sales Rep", "SDR", "BDR", "Account Executive" |
| Excluding competitors | "[Competitor name]", "[Competitor product]" |
| Targeting active roles | "Retired", "Former", "Ex-", "Board Advisor" |
| Targeting decision makers | "Coordinator", "Assistant", "Associate", "Junior" |

## Subsegment Keyword Sets

Pre-built keyword sets for common subsegment scans. Use these when the user wants to target a niche within their broader ICP.

### Consulting Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| Recruitment consultants | "Recruitment", "Talent", "Staffing", "Executive Search", "Talent Acquisition" |
| IT consultants | "IT Consulting", "Technology Advisor", "Digital Transformation", "IT Strategy" |
| Management consultants | "Management Consulting", "Strategy Consulting", "Business Transformation" |
| Financial consultants | "Financial Advisor", "Wealth Management", "CFO Services", "Financial Planning" |
| HR consultants | "HR Consulting", "People Strategy", "Organizational Development", "Culture" |

### SaaS Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| AI/ML SaaS | "AI", "Machine Learning", "GPT", "LLM", "Artificial Intelligence", "ML" |
| FinTech SaaS | "FinTech", "Financial Technology", "Banking", "Payments", "Lending" |
| HR Tech | "HR Tech", "People Platform", "HRIS", "Talent Management" |
| MarTech | "Marketing Technology", "MarTech", "Marketing Automation", "CRM" |
| DevTools | "Developer Tools", "DevOps", "Platform Engineering", "Infrastructure" |

### Coaching Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| Executive coaches for tech | "Executive Coach", "Leadership Coach", "CTO Coach", "Tech Leader" |
| Career coaches | "Career Coach", "Career Transition", "Career Strategy", "Job Search" |
| Business coaches | "Business Coach", "Growth Coach", "Entrepreneur Coach", "Scale" |
| Sales coaches | "Sales Coach", "Revenue Coach", "Sales Trainer", "Sales Leadership" |

### Agency Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| SEO agencies | "SEO Agency", "Search Marketing", "Organic Growth", "SEO Specialist" |
| Paid media agencies | "PPC", "Paid Media", "Performance Marketing", "Google Ads", "Meta Ads" |
| Creative / branding | "Creative Director", "Brand Agency", "Design Agency", "Brand Strategy" |
| Web development | "Web Agency", "Development Agency", "WordPress", "Shopify", "Web Studio" |
| Content agencies | "Content Agency", "Content Strategy", "Copywriting Agency", "Content Marketing" |

## Keyword Quality Checklist

Before running a scan, verify:

- [ ] At least 3-5 include keywords to cast a reasonable net
- [ ] Include keywords map to actual headline language (not marketing copy)
- [ ] Exclude keywords filter obvious non-matches without over-filtering
- [ ] Keywords cover title variations (VP vs Director vs Head of)
- [ ] Industry terms match how people self-describe (not how outsiders describe them)
