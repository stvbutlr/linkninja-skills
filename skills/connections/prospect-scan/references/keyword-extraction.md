# ICP-to-Keyword Extraction Guide

How to translate an ICP description into headline keywords for `scan_connections`. The ICP describes who the user sells to. Headlines describe who the person is. This table maps one to the other.

## Core Translation Table

| ICP Element | Headline Signal | Keyword Examples |
|-------------|----------------|-----------------|
| Service offering | What they sell or help with | "Coach", "Consultant", "Advisor", "Strategist", "Specialist" |
| Niche / vertical | Their specific area | "Recruitment", "Wealth Management", "Leadership", "SEO", "Career", "Wellness" |
| Business model | How they operate | "Founder", "Owner", "Solo", "Boutique", "Practice", "Independent" |
| Buyer titles (when targeting buyers) | Direct title match | "Founder", "CEO", "Owner", "Managing Director", "Principal", "Partner" |
| Seniority (when targeting employers) | Level markers | "Director", "VP", "Head of", "Chief", "Partner" |
| Industry / sector (broader) | Company or sector terms | "Financial Services", "Healthcare", "Professional Services", "Creative", "B2B Services" |

## Include Keywords: Expansion Patterns

When the initial scan is too narrow, expand with adjacent terms.

### Title Expansions

| Core Title | Adjacent Titles |
|-----------|----------------|
| Consultant | Advisor, Strategist, Specialist, Expert, Practitioner |
| Coach | Mentor, Facilitator, Trainer, Guide |
| Financial Advisor | Wealth Manager, Financial Planner, Investment Advisor, Private Wealth |
| Agency Owner | Creative Director, Managing Partner, Agency Founder, Founder |
| Founder | Co-Founder, CEO, Managing Director, Owner, Principal |
| Fractional [X] | Interim [X], Part-time [X], On-Demand [X] |
| Service Provider | Specialist, Practitioner, Boutique [X] |

### Industry Expansions

| Core Term | Adjacent Terms |
|----------|---------------|
| Professional Services | Consulting, Advisory, Strategy, Business Services |
| Coaching | Personal Development, Mentoring, Training, Performance |
| Financial Services | Wealth Management, Financial Planning, Advisory, Investment |
| Creative Services | Branding, Design, Content, Marketing |
| Wellness / Health | Coaching, Therapy, Nutrition, Fitness |
| Recruiting / Talent | Talent Acquisition, Staffing, HR Consulting, People Operations |

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
| Management consultants | "Management Consulting", "Strategy Consulting", "Business Transformation" |
| HR consultants | "HR Consulting", "People Strategy", "Organizational Development", "Culture" |
| IT / digital transformation consultants | "IT Consulting", "Technology Advisor", "Digital Transformation", "IT Strategy" |
| Marketing consultants | "Marketing Consultant", "Demand Gen Consultant", "Brand Strategist" |
| Operations consultants | "Operations Consulting", "Process Improvement", "Operational Excellence" |
| Sustainability / ESG consultants | "Sustainability", "ESG Advisor", "Climate Consultant" |

### Coaching Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| Executive coaches | "Executive Coach", "Leadership Coach", "C-Suite Coach" |
| Career coaches | "Career Coach", "Career Transition", "Career Strategy", "Job Search" |
| Business / founder coaches | "Business Coach", "Growth Coach", "Founder Coach", "Entrepreneur Coach" |
| Sales coaches | "Sales Coach", "Revenue Coach", "Sales Trainer", "Sales Leadership" |
| Performance / mindset coaches | "Performance Coach", "Mindset Coach", "High Performance" |
| Health / wellness coaches | "Health Coach", "Nutrition Coach", "Wellness Coach" |
| Creative / artist coaches | "Creative Coach", "Artist Coach", "Author Coach" |

### Financial Advisory Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| Independent financial advisors | "Financial Advisor", "Independent Advisor", "Fiduciary" |
| Wealth managers | "Wealth Manager", "Private Wealth", "Wealth Advisor", "Family Office" |
| Fractional CFOs | "Fractional CFO", "CFO Services", "Outsourced CFO", "Part-Time CFO" |
| Tax / accounting specialists | "Tax Advisor", "Tax Strategist", "Specialist Accountant", "Boutique CPA" |
| Investment advisors | "Investment Advisor", "Portfolio Manager", "Asset Management" |

### Agency Niches

| Subsegment | Include Keywords |
|-----------|-----------------|
| SEO agencies | "SEO Agency", "Search Marketing", "Organic Growth", "SEO Specialist" |
| Paid media agencies | "PPC", "Paid Media", "Performance Marketing", "Google Ads", "Meta Ads" |
| Creative / branding | "Creative Director", "Brand Agency", "Design Agency", "Brand Strategy" |
| Web development | "Web Agency", "Development Agency", "WordPress", "Shopify", "Web Studio" |
| Content agencies | "Content Agency", "Content Strategy", "Copywriting Agency", "Content Marketing" |
| LinkedIn / social media agencies | "LinkedIn Agency", "Social Media Strategist", "Personal Brand" |

### Niche Service Sellers

| Subsegment | Include Keywords |
|-----------|-----------------|
| Course creators / educators | "Course Creator", "Educator", "Online Course", "Curriculum" |
| Authors / thought leaders | "Author", "Speaker", "Thought Leader", "Keynote" |
| Specialist freelancers | "Copywriter", "Designer", "Developer", "Editor", "Producer" |
| Fractional executives | "Fractional CMO", "Fractional COO", "Fractional CTO", "Interim Leader" |
| Therapists / counsellors | "Therapist", "Counsellor", "Psychologist", "Mental Health" |

## Keyword Quality Checklist

Before running a scan, verify:

- [ ] At least 3-5 include keywords to cast a reasonable net
- [ ] Include keywords map to actual headline language (not marketing copy)
- [ ] Exclude keywords filter obvious non-matches without over-filtering
- [ ] Keywords cover title variations (VP vs Director vs Head of)
- [ ] Industry terms match how people self-describe (not how outsiders describe them)
