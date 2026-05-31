document.addEventListener("DOMContentLoaded", () => {
    // Config & endpoints
    const LIVE_URL = "http://localhost:8080/drift_report.json";
    const MOCK_URL = "assets/mock_drift_report.json";

    // Navigation Selectors
    const navDashboard = document.getElementById("nav-dashboard");
    const navGettingStarted = document.getElementById("nav-getting-started");
    const getStartedBtn = document.getElementById("get-started-btn");
    const dashboardContent = document.getElementById("dashboard-content");
    const gettingStartedContent = document.getElementById("getting-started-content");
    const documentationContent = document.getElementById("documentation-content");
    const apiStatusContent = document.getElementById("api-status-content");
    const supportContent = document.getElementById("support-content");
    const privacyContent = document.getElementById("privacy-content");
    const mainLoader = document.getElementById("main-loader");
    const statusContainer = document.getElementById("status-container");

    // Footer Links Selectors
    const footerDocumentation = document.getElementById("footer-documentation");
    const footerApi = document.getElementById("footer-api");
    const footerSupport = document.getElementById("footer-support");
    const footerPrivacy = document.getElementById("footer-privacy");

    // Support Page Selectors
    const supportForm = document.getElementById("support-form");
    const supportSuccessOverlay = document.getElementById("support-success-overlay");
    const resetSupportBtn = document.getElementById("reset-support-btn");

    // Theme Switcher Selectors
    const themeToggle = document.getElementById("theme-toggle");
    const themeIcon = document.getElementById("theme-icon");

    // Live Toggle Selectors
    const liveToggle = document.getElementById("live-toggle");
    const toggleIndicator = document.getElementById("toggle-indicator");
    const toggleText = document.getElementById("toggle-text");

    // Data elements
    const userSubtitle = document.getElementById("user-subtitle");
    const totalScore = document.getElementById("total-score");
    const scoreDeltaBadge = document.getElementById("score-delta-badge");
    const scoreDeltaIcon = document.getElementById("score-delta-icon");
    const scoreDeltaValue = document.getElementById("score-delta-value");
    const topPriorityContainer = document.getElementById("top-priority-container");

    const aiInsightCard = document.getElementById("ai-insight-card");
    const aiInsightText = document.getElementById("ai-insight-text");
    const aiPlanContainer = document.getElementById("ai-plan-container");
    const aiPlanList = document.getElementById("ai-plan-list");

    const categoryLists = {
        review: {
            list: document.getElementById("review-list"),
            count: document.getElementById("review-count"),
            noun: "Item"
        },
        reply: {
            list: document.getElementById("reply-list"),
            count: document.getElementById("reply-count"),
            noun: "Item"
        },
        commitment: {
            list: document.getElementById("commitment-list"),
            count: document.getElementById("commitment-count"),
            noun: "Item"
        },
        staleness: {
            list: document.getElementById("staleness-list"),
            count: document.getElementById("staleness-count"),
            noun: "Item"
        },
        drift: {
            list: document.getElementById("drift-list"),
            count: document.getElementById("drift-count"),
            noun: "Conflict"
        }
    };

    // State Variables
    let isLive = localStorage.getItem("drift_is_live") === "true";
    let activePage = "dashboard"; // "dashboard" or "getting-started"
    let hasStarted = localStorage.getItem("drift_has_started") === "true";
    let currentTheme = localStorage.getItem("drift_theme") || "dark";
    let reportData = null; // cached copy of report data

    // --- Theme Switching Initialization ---
    applyTheme(currentTheme);

    themeToggle.addEventListener("click", () => {
        currentTheme = currentTheme === "dark" ? "light" : "dark";
        localStorage.setItem("drift_theme", currentTheme);
        applyTheme(currentTheme);
    });

    function applyTheme(theme) {
        const html = document.documentElement;
        if (theme === "light") {
            html.classList.remove("dark");
            html.classList.add("light");
            themeIcon.textContent = "dark_mode";
            themeToggle.title = "Switch to Dark Mode";
        } else {
            html.classList.remove("light");
            html.classList.add("dark");
            themeIcon.textContent = "light_mode";
            themeToggle.title = "Switch to Light Mode";
        }
    }

    // --- Navigation Routing ---
    // If first-time visitor, land on getting started page
    if (!hasStarted) {
        navigateTo("getting-started");
    } else {
        navigateTo("dashboard");
    }

    navDashboard.addEventListener("click", () => navigateTo("dashboard"));
    navGettingStarted.addEventListener("click", () => navigateTo("getting-started"));
    
    getStartedBtn.addEventListener("click", () => {
        localStorage.setItem("drift_has_started", "true");
        hasStarted = true;
        navigateTo("dashboard");
    });

    function navigateTo(page) {
        activePage = page;
        
        // Hide all views first
        gettingStartedContent.classList.add("hidden");
        dashboardContent.classList.add("hidden");
        documentationContent.classList.add("hidden");
        apiStatusContent.classList.add("hidden");
        supportContent.classList.add("hidden");
        privacyContent.classList.add("hidden");
        mainLoader.classList.add("hidden");
        statusContainer.classList.add("hidden");

        // Reset navigation visual active indicators
        navDashboard.className = "text-textSecondary font-medium hover:text-primary transition-colors duration-200 nav-link-glow cursor-pointer";
        navGettingStarted.className = "text-textSecondary font-medium hover:text-primary transition-colors duration-200 nav-link-glow cursor-pointer";

        if (page === "getting-started") {
            gettingStartedContent.classList.remove("hidden");
            navGettingStarted.className = "text-primary font-bold nav-link-glow cursor-pointer nav-active";
        } else if (page === "documentation") {
            documentationContent.classList.remove("hidden");
        } else if (page === "api-status") {
            apiStatusContent.classList.remove("hidden");
            const apiTime = document.getElementById("api-time");
            if (apiTime) {
                apiTime.textContent = new Date().toLocaleTimeString();
            }
        } else if (page === "support") {
            supportContent.classList.remove("hidden");
        } else if (page === "privacy") {
            privacyContent.classList.remove("hidden");
        } else {
            // Show Dashboard
            navDashboard.className = "text-primary font-bold nav-link-glow cursor-pointer nav-active";
            
            // If data is already cached, render it immediately, else fetch
            if (reportData) {
                renderDashboard(reportData);
                dashboardContent.classList.remove("hidden");
            } else {
                fetchReport();
            }
        }
        
        // Scroll back to top on page change
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // --- Live / Mock Data Fetching & Toggle ---
    updateToggleUI();

    liveToggle.addEventListener("click", () => {
        isLive = !isLive;
        localStorage.setItem("drift_is_live", isLive);
        updateToggleUI();
        
        // Force reload report data on toggle
        reportData = null; 
        if (activePage === "dashboard") {
            fetchReport();
        }
    });

    function updateToggleUI() {
        if (isLive) {
            liveToggle.className = "flex items-center gap-sm bg-surfaceElevated rounded-lg px-3 py-1.5 border border-success/30 shadow-[inset_0_1px_2px_rgba(0,0,0,0.3),_0_1px_1px_rgba(255,255,255,0.05),_0_0_8px_rgba(34,197,94,0.15)] cursor-pointer hover:bg-surfaceOverlay transition-all duration-300";
            toggleIndicator.innerHTML = `
                <span class="absolute inset-0 rounded-full bg-success opacity-40 animate-ping"></span>
                <span class="absolute inset-0 rounded-full bg-success shadow-[0_0_8px_#22C55E]"></span>
            `;
            toggleText.textContent = "LIVE";
            toggleText.className = "font-label text-label text-success tracking-widest";
        } else {
            liveToggle.className = "flex items-center gap-sm bg-surfaceElevated rounded-lg px-3 py-1.5 border border-borderSubtle shadow-[inset_0_1px_2px_rgba(0,0,0,0.3),_0_1px_1px_rgba(255,255,255,0.05)] cursor-pointer hover:bg-surfaceOverlay transition-all duration-300";
            toggleIndicator.innerHTML = `
                <span class="absolute inset-0 rounded-full bg-textMuted/40"></span>
                <span class="absolute inset-0 rounded-full bg-textMuted"></span>
            `;
            toggleText.textContent = "MOCK";
            toggleText.className = "font-label text-label text-textSecondary tracking-widest";
        }
    }

    async function fetchReport() {
        if (activePage !== "dashboard") return;

        showLoader();
        statusContainer.classList.add("hidden");
        statusContainer.innerHTML = "";

        const url = isLive ? LIVE_URL : MOCK_URL;
        
        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`Server returned status ${response.status}`);
            }
            const data = await response.json();
            reportData = data;
            renderDashboard(data);
            hideLoader();
        } catch (error) {
            console.error("Error loading report:", error);
            showError(error);
            hideLoader();
        }
    }

    function showLoader() {
        mainLoader.classList.remove("hidden");
        dashboardContent.classList.add("hidden");
    }

    function hideLoader() {
        mainLoader.classList.add("hidden");
        dashboardContent.classList.remove("hidden");
    }

    function showError(error) {
        dashboardContent.classList.add("hidden");
        statusContainer.classList.remove("hidden");

        statusContainer.innerHTML = `
            <section class="bg-error/10 border border-error/20 rounded-xl p-lg flex flex-col md:flex-row justify-between items-start md:items-center gap-lg animate-fade-in-up">
                <div class="flex items-start gap-md">
                    <div class="w-10 h-10 rounded-lg bg-error/10 flex items-center justify-center text-error flex-shrink-0">
                        <span class="material-symbols-outlined">error</span>
                    </div>
                    <div>
                        <h3 class="font-h3 text-h3 text-error mb-1">Could not reach the report server</h3>
                        <p class="font-body-md text-body-md text-textSecondary mb-2">
                            Unable to fetch data from <code class="bg-surface-container px-1 py-0.5 rounded text-textPrimary text-sm font-mono">${isLive ? LIVE_URL : MOCK_URL}</code>.
                        </p>
                        <div class="space-y-1 text-sm text-textMuted">
                            <p>1. Start the server using: <code class="bg-surface-container px-1 py-0.5 rounded font-mono text-xs">./scripts/serve_report.sh</code></p>
                            <p>2. Verify backend output file exists: <code class="bg-surface-container px-1 py-0.5 rounded font-mono text-xs">backend/data/drift_report.json</code></p>
                        </div>
                    </div>
                </div>
                <div class="flex gap-md w-full md:w-auto">
                    <button id="retry-btn" class="bg-surfaceElevated text-textPrimary border border-borderSubtle hover:bg-surfaceOverlay rounded-md px-4 py-2 font-body-sm text-body-sm transition-colors flex-1 md:flex-none">Retry Live</button>
                    <button id="switch-mock-btn" class="bg-error/10 text-error border border-error/30 hover:bg-error/20 rounded-md px-4 py-2 font-body-sm text-body-sm transition-colors flex-1 md:flex-none">Use Mock Data</button>
                </div>
            </section>
        `;

        document.getElementById("retry-btn").addEventListener("click", () => {
            fetchReport();
        });

        document.getElementById("switch-mock-btn").addEventListener("click", () => {
            isLive = false;
            localStorage.setItem("drift_is_live", false);
            updateToggleUI();
            fetchReport();
        });
    }

    function animateCountUp(element, targetValue) {
        if (isNaN(targetValue)) {
            element.textContent = targetValue;
            return;
        }
        const startValue = parseInt(element.textContent) || 0;
        if (startValue === targetValue) {
            element.textContent = targetValue;
            return;
        }
        const duration = 800; // 0.8 seconds
        const startTime = performance.now();

        function update(currentTime) {
            const elapsedTime = currentTime - startTime;
            if (elapsedTime >= duration) {
                element.textContent = targetValue;
                return;
            }
            const progress = elapsedTime / duration;
            // easeOutQuad curve
            const easeProgress = progress * (2 - progress);
            const currentValue = Math.round(startValue + (targetValue - startValue) * easeProgress);
            element.textContent = currentValue;
            requestAnimationFrame(update);
        }
        requestAnimationFrame(update);
    }

    function renderDashboard(report) {
        // User & Subtitle
        userSubtitle.textContent = `${report.user || "agp"}'s current cognitive load and blocking tasks.`;

        // Score
        if (report.score !== undefined) {
            animateCountUp(totalScore, report.score);
        } else {
            totalScore.textContent = "--";
        }

        // Score Delta Badge
        const delta = report.score_delta || 0;
        if (delta > 0) {
            scoreDeltaBadge.className = "flex items-center text-scoreUp bg-scoreUp/10 px-2 py-1 rounded";
            scoreDeltaIcon.textContent = "arrow_upward";
            scoreDeltaValue.textContent = delta;
            scoreDeltaBadge.classList.remove("hidden");
        } else if (delta < 0) {
            scoreDeltaBadge.className = "flex items-center text-scoreDown bg-scoreDown/10 px-2 py-1 rounded";
            scoreDeltaIcon.textContent = "arrow_downward";
            scoreDeltaValue.textContent = Math.abs(delta);
            scoreDeltaBadge.classList.remove("hidden");
        } else {
            scoreDeltaBadge.classList.add("hidden");
        }

        // Top Priority Action Banner
        renderTopPriorityBanner(report.top_action);

        // AI Insight
        if (report.insight) {
            aiInsightText.textContent = report.insight;
            aiInsightCard.classList.remove("hidden");

            if (report.suggested_plan && report.suggested_plan.length > 0) {
                aiPlanContainer.classList.remove("hidden");
                aiPlanList.innerHTML = "";
                report.suggested_plan.forEach((step, idx) => {
                    const stepDiv = document.createElement("div");
                    stepDiv.className = "flex items-start gap-md";
                    stepDiv.innerHTML = `
                        <div class="flex-shrink-0 w-5 h-5 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary text-caption font-bold font-mono">
                            ${idx + 1}
                        </div>
                        <span class="font-body-md text-body-md text-textPrimary">${step}</span>
                    `;
                    aiPlanList.appendChild(stepDiv);
                });
            } else {
                aiPlanContainer.classList.add("hidden");
            }
        } else {
            aiInsightCard.classList.add("hidden");
        }

        // Debts Categories
        const debts = report.debts || {};
        renderCategoryList("review", debts.review || []);
        renderCategoryList("reply", debts.reply || []);
        renderCategoryList("commitment", debts.commitment || []);
        renderCategoryList("staleness", debts.staleness || []);
        renderCategoryList("drift", debts.drift || []);
    }

    function renderTopPriorityBanner(topAction) {
        if (!topAction || !topAction.text || topAction.type === "none") {
            topPriorityContainer.innerHTML = "";
            return;
        }

        const type = topAction.type.toLowerCase();
        let accentColor = "textMuted";
        let iconName = "warning";
        let typeLabel = "ATTENTION DEBT";
        let ctaLabel = "Open Link";

        if (type === "review") {
            accentColor = "review";
            iconName = "visibility";
            typeLabel = "REVIEW DEBT";
            ctaLabel = "Review PR";
        } else if (type === "reply") {
            accentColor = "reply";
            iconName = "forum";
            typeLabel = "REPLY DEBT";
            ctaLabel = "Reply";
        } else if (type === "commitment") {
            accentColor = "commitment";
            iconName = "task_alt";
            typeLabel = "COMMITMENT DEBT";
            ctaLabel = "View Task";
        } else if (type === "staleness") {
            accentColor = "staleness";
            iconName = "hourglass_empty";
            typeLabel = "STALENESS DEBT";
            ctaLabel = "View PR";
        } else if (type === "drift") {
            accentColor = "drift";
            iconName = "compare_arrows";
            typeLabel = "DRIFT DEBT";
            ctaLabel = "Inspect Conflict";
        }

        const hasUrl = topAction.url && topAction.url.trim() !== "";
        if (hasUrl) {
            try {
                const host = new URL(topAction.url).host.toLowerCase();
                if (host.includes("github.com")) ctaLabel = "Open in GitHub →";
                else if (host.includes("linear.app")) ctaLabel = "Open in Linear →";
                else if (host.includes("slack.com")) ctaLabel = "Open in Slack →";
                else if (host.includes("notion.so")) ctaLabel = "Open in Notion →";
            } catch (_) {}
        }

        topPriorityContainer.innerHTML = `
            <section class="bg-surfaceElevated rounded-xl border border-${accentColor}/20 p-md flex flex-col md:flex-row items-start md:items-center justify-between hover:bg-surfaceOverlay transition-all duration-300 cursor-pointer glow-${type} animate-fade-in-up" style="animation-delay: 0.2s;">
                <div class="flex items-center gap-md mb-md md:mb-0">
                    <div class="w-10 h-10 rounded-lg bg-${accentColor}/10 flex items-center justify-center text-${accentColor}">
                        <span class="material-symbols-outlined">${iconName}</span>
                    </div>
                    <div>
                        <span class="font-label text-label text-${accentColor} block mb-1">TOP PRIORITY • ${typeLabel}</span>
                        <h3 class="font-h2 text-h2 text-textPrimary">${topAction.text}</h3>
                    </div>
                </div>
                ${hasUrl ? `
                <button class="w-full md:w-auto bg-${accentColor}/10 text-${accentColor} border border-${accentColor}/30 rounded-md px-4 py-2 font-body-sm text-body-sm hover:bg-${accentColor}/20 transition-all duration-200">${ctaLabel}</button>
                ` : ""}
            </section>
        `;

        if (hasUrl) {
            topPriorityContainer.querySelector("section").addEventListener("click", () => {
                window.open(topAction.url, "_blank");
            });
        }
    }

    function renderCategoryList(catName, items) {
        const cat = categoryLists[catName];
        if (!cat) return;

        const countText = items.length === 1 ? `1 ${cat.noun}` : `${items.length} ${cat.noun}s`;
        cat.count.textContent = countText;

        cat.list.innerHTML = "";

        if (items.length === 0) {
            cat.list.innerHTML = `
                <div class="p-md flex items-center gap-sm bg-surfaceOverlay/5">
                    <span class="text-success text-lg">✅</span>
                    <span class="font-body-md text-body-md text-textSecondary">You're caught up — no items waiting for you</span>
                </div>
            `;
            return;
        }

        items.forEach((item) => {
            const row = document.createElement("div");
            
            if (catName === "review") {
                row.className = "p-md hover:bg-surfaceOverlay transition-all duration-200 cursor-pointer flex justify-between items-center";
                if (item.url) {
                    row.addEventListener("click", () => window.open(item.url, "_blank"));
                }
                const blocksStr = item.blocks ? ` · ⛓ ${item.blocks}` : "";
                row.innerHTML = `
                    <div>
                        <span class="font-body-md text-body-md text-textPrimary block">PR #${item.pr_number}: ${item.title}</span>
                        <span class="font-caption text-caption text-textMuted">${item.repo} · ⏱ ${item.days_waiting} days · 💬 ${item.slack_mentions} Slack asks${blocksStr} · Requested by @${item.author}</span>
                    </div>
                    ${item.url ? '<span class="material-symbols-outlined text-textMuted text-sm">open_in_new</span>' : ""}
                `;
            } 
            
            else if (catName === "reply") {
                row.className = "p-md hover:bg-surfaceOverlay transition-all duration-200 flex justify-between items-center";
                const icons = { slack: "💬", notion: "📝", linear: "📌", github: "🐙" };
                const sourceIcon = icons[item.source?.toLowerCase()] || "🔔";
                const sourceLabel = item.source ? item.source.charAt(0).toUpperCase() + item.source.slice(1) : "";
                const channelLabel = item.source?.toLowerCase() === "slack" ? "#" + item.channel.replace("#", "") : item.channel;
                const daysStr = item.days_ago === 1 ? "1 day ago" : `${item.days_ago} days ago`;
                row.innerHTML = `
                    <div>
                        <span class="font-body-md text-body-md text-textPrimary block">${sourceIcon} ${sourceLabel} ${channelLabel} · @${item.from} · ${daysStr}</span>
                        <span class="font-caption text-caption text-textMuted italic">"${item.preview}"</span>
                    </div>
                `;
            } 
            
            else if (catName === "commitment") {
                row.className = "p-md hover:bg-surfaceOverlay transition-all duration-200 flex justify-between items-center";
                const isStaleWarning = item.days_stale >= 10;
                row.innerHTML = `
                    <div>
                        <span class="font-body-md text-body-md text-textPrimary block">${item.task_id} · "${item.title}"</span>
                        <span class="font-caption text-caption text-textMuted">Status: ${item.status} · Last commit: ${item.days_stale}d ago</span>
                        ${isStaleWarning ? `
                        <div class="mt-1.5 text-warning text-caption font-semibold flex items-center gap-1">
                            <span class="material-symbols-outlined text-xs">warning</span>
                            <span>No Git activity matching this task</span>
                        </div>
                        ` : ""}
                    </div>
                `;
            } 
            
            else if (catName === "staleness") {
                row.className = "p-md hover:bg-surfaceOverlay transition-all duration-200 cursor-pointer flex justify-between items-center";
                if (item.url) {
                    row.addEventListener("click", () => window.open(item.url, "_blank"));
                }
                const noReviews = item.reviews === 0;
                row.innerHTML = `
                    <div>
                        <span class="font-body-md text-body-md text-textPrimary block">PR #${item.pr_number}: ${item.title}</span>
                        <span class="font-caption text-caption text-textMuted">${item.repo} · Open ${item.days_stale} days · ${item.reviews} reviews</span>
                        ${noReviews ? `
                        <div class="mt-1.5 text-textMuted text-caption flex items-center gap-1">
                            <span class="material-symbols-outlined text-xs">lightbulb</span>
                            <span>Nobody's looking at it. Ping #frontend?</span>
                        </div>
                        ` : ""}
                    </div>
                    ${item.url ? '<span class="material-symbols-outlined text-textMuted text-sm">open_in_new</span>' : ""}
                `;
            } 
            
            else if (catName === "drift") {
                row.className = "p-md hover:bg-surfaceOverlay transition-all duration-200 flex justify-between items-center";
                row.innerHTML = `
                    <div class="w-full">
                        <div class="flex flex-col md:flex-row md:items-center gap-md">
                            <div class="flex-1">
                                <span class="font-label text-label text-textMuted block mb-1">LINEAR TASK (${item.task_id})</span>
                                <span class="font-body-md text-body-md text-textPrimary block">${item.task_title} (marked ${item.task_status})</span>
                            </div>
                            <div class="hidden md:block">
                                <span class="material-symbols-outlined text-textMuted">arrow_forward</span>
                            </div>
                            <div class="flex-1">
                                <span class="font-label text-label text-textMuted block mb-1">GITHUB PR</span>
                                <span class="font-body-md text-body-md text-textPrimary block">PR #${item.pr_number} (status: ${item.pr_status})</span>
                            </div>
                        </div>
                        <div class="mt-3 text-drift text-body-sm font-semibold flex items-start gap-1">
                            <span class="material-symbols-outlined text-xs mt-0.5">warning</span>
                            <span>${item.contradiction}</span>
                        </div>
                    </div>
                `;
            }

            cat.list.appendChild(row);
        });
    }

    // --- Footer Navigation Listeners ---
    footerDocumentation.addEventListener("click", () => navigateTo("documentation"));
    footerApi.addEventListener("click", () => navigateTo("api-status"));
    footerSupport.addEventListener("click", () => navigateTo("support"));
    footerPrivacy.addEventListener("click", () => navigateTo("privacy"));

    // --- Support Page Form Submission ---
    if (supportForm) {
        supportForm.addEventListener("submit", (e) => {
            e.preventDefault();
            
            // Slide/fade in success overlay smoothly
            supportSuccessOverlay.classList.remove("opacity-0", "pointer-events-none");
            supportSuccessOverlay.classList.add("opacity-100");
            
            // Clear inputs
            document.getElementById("support-email").value = "";
            document.getElementById("support-message").value = "";
        });
    }

    if (resetSupportBtn) {
        resetSupportBtn.addEventListener("click", () => {
            // Slide/fade out success overlay
            supportSuccessOverlay.classList.remove("opacity-100");
            supportSuccessOverlay.classList.add("opacity-0", "pointer-events-none");
        });
    }
});
