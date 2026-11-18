//! Links to tasks ("Copy Link"): Tend writes `tend://task/<id>`.
//! Older `fern://task/<id>` links remain readable after migration.

use crate::model::Id;

const TASK_PREFIX: &str = "tend://task/";
const LEGACY_TASK_PREFIX: &str = "fern://task/";

pub fn task_link(id: Id) -> String {
    format!("{TASK_PREFIX}{id}")
}

/// Resolve a task link from Tend or from the original Fern application.
pub fn parse_task_link(text: &str) -> Option<Id> {
    let text = text.trim();
    let id = text
        .strip_prefix(TASK_PREFIX)
        .or_else(|| text.strip_prefix(LEGACY_TASK_PREFIX))?;
    id.trim_end_matches('/').parse().ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip_and_legacy_links() {
        let id = uuid::Uuid::now_v7();
        assert_eq!(task_link(id), format!("tend://task/{id}"));
        assert_eq!(parse_task_link(&task_link(id)), Some(id));
        assert_eq!(parse_task_link(&format!(" {}/ ", task_link(id))), Some(id));
        assert_eq!(parse_task_link(&format!("fern://task/{id}")), Some(id));
        assert_eq!(parse_task_link("https://example.com/task/1"), None);
        assert_eq!(parse_task_link("fern://task/not-an-id"), None);
        assert_eq!(parse_task_link("tend://task/not-an-id"), None);
    }
}
