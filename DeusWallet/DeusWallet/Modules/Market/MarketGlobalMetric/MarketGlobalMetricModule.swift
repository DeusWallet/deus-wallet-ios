import Chart
import ThemeKit
import UIKit

enum MarketGlobalMetricModule {
    static func viewController(type: MarketGlobalModule.MetricsType) -> UIViewController {
        let viewController: UIViewController

        switch type {
        case .totalMarketCap, .volume24h: viewController = globalMetricViewController(type: type)
        case .defiCap: viewController = defiCapViewController()
        case .tvlInDefi: viewController = tvlInDefiViewController()
        }

        return ThemeNavigationController(rootViewController: viewController)
    }

    private static func globalMetricViewController(type: MarketGlobalModule.MetricsType) -> UIViewController {
        let service = MarketGlobalMetricService(
            marketKit: App.shared.marketKit,
            currencyManager: App.shared.currencyManager,
            metricsType: type
        )

        let watchlistToggleService = MarketWatchlistToggleService(
            coinUidService: service,
            favoritesManager: App.shared.favoritesManager,
            statPage: type.statPage
        )

        let decorator = MarketListMarketFieldDecorator(service: service, statPage: type.statPage)
        let listViewModel = MarketListWatchViewModel(service: service, watchlistToggleService: watchlistToggleService, decorator: decorator)
        let headerViewModel = MarketSingleSortHeaderViewModel(service: service, decorator: decorator)

        let chartFetcher = MarketGlobalFetcher(currencyManager: App.shared.currencyManager, marketKit: App.shared.marketKit, metricsType: type)
        let chartService = MetricChartService(
            chartFetcher: chartFetcher,
            interval: .byPeriod(.day1),
            statPage: type.statPage
        )

        let factory = MetricChartFactory(currentLocale: LanguageManager.shared.currentLocale)
        let chartViewModel = MetricChartViewModel(service: chartService, factory: factory)

        return MarketGlobalMetricViewController(listViewModel: listViewModel, headerViewModel: headerViewModel, chartViewModel: chartViewModel, metricsType: type)
    }

    private static func defiCapViewController() -> UIViewController {
        let service = MarketGlobalDefiMetricService(
            marketKit: App.shared.marketKit,
            currencyManager: App.shared.currencyManager
        )

        let watchlistToggleService = MarketWatchlistToggleService(
            coinUidService: service,
            favoritesManager: App.shared.favoritesManager,
            statPage: .globalMetricsDefiCap
        )

        let decorator = MarketListDefiDecorator(service: service)
        let listViewModel = MarketListWatchViewModel(service: service, watchlistToggleService: watchlistToggleService, decorator: decorator)
        let headerViewModel = MarketSingleSortHeaderViewModel(service: service, decorator: decorator)

        let chartFetcher = MarketGlobalFetcher(currencyManager: App.shared.currencyManager, marketKit: App.shared.marketKit, metricsType: .defiCap)
        let chartService = MetricChartService(
            chartFetcher: chartFetcher,
            interval: .byPeriod(.day1),
            statPage: .globalMetricsDefiCap
        )

        let factory = MetricChartFactory(currentLocale: LanguageManager.shared.currentLocale)
        let chartViewModel = MetricChartViewModel(service: chartService, factory: factory)

        return MarketGlobalMetricViewController(listViewModel: listViewModel, headerViewModel: headerViewModel, chartViewModel: chartViewModel, metricsType: MarketGlobalModule.MetricsType.defiCap)
    }

    static func tvlInDefiViewController() -> UIViewController {
        let service = MarketGlobalTvlMetricService(
            marketKit: App.shared.marketKit,
            currencyManager: App.shared.currencyManager
        )

        let watchlistToggleService = MarketWatchlistToggleService(
            coinUidService: service,
            favoritesManager: App.shared.favoritesManager,
            statPage: .globalMetricsTvlInDefi
        )

        let decorator = MarketListTvlDecorator(service: service)
        let listViewModel = MarketListWatchViewModel(service: service, watchlistToggleService: watchlistToggleService, decorator: decorator)
        let headerViewModel = MarketTvlSortHeaderViewModel(service: service, decorator: decorator)

        let chartFetcher = MarketGlobalTvlFetcher(marketKit: App.shared.marketKit, currencyManager: App.shared.currencyManager, marketGlobalTvlPlatformService: service)
        let chartService = MetricChartService(
            chartFetcher: chartFetcher,
            interval: .byPeriod(.day1),
            statPage: .globalMetricsTvlInDefi
        )
        service.chartService = chartService

        let factory = MetricChartFactory(currentLocale: LanguageManager.shared.currentLocale)
        let chartViewModel = MetricChartViewModel(service: chartService, factory: factory)

        return MarketGlobalTvlMetricViewController(listViewModel: listViewModel, headerViewModel: headerViewModel, chartViewModel: chartViewModel)
    }
}
